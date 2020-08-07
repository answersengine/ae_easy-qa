module AeEasy
  module Qa
    class ValidateInternal
      attr_reader :scraper_name, :collections, :rules, :outputs, :data

      def initialize(vars, config, outputs)
        @scraper_name = vars['scraper_name']
        @collections = vars['collections']
        @rules = config['individual_validations']
        @outputs = outputs
        @data = vars['data']
      end

      def run
        begin
          ValidateScraper.new(scraper_name, collections, rules, outputs, thresholds, data).run
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end

      private

      #thresholds are a setting where you can suppress errors if they are under a specific error rate
      def thresholds
        @thresholds ||= begin
                          file_path = File.expand_path('thresholds.yaml', Dir.pwd)
                          if File.exists? file_path
                            YAML.load(File.open(file_path))
                          else
                            nil
                          end
                        end
      end
    end

    class ValidateScraper
      attr_reader :scraper_name, :collections, :rules, :outputs, :options, :data

      def initialize(scraper_name, collections, rules, outputs, thresholds, data)
        @scraper_name = scraper_name
        @collections = collections
        @rules = rules
        @outputs = outputs
        @options = {}
        @data = data
        options['thresholds'] = thresholds[scraper_name] if thresholds && thresholds[scraper_name]
      end

      def run
        begin
          output_scraper
          if status_ok?
            validate_collections if collections && collections.any?
          else
            output_response
            return nil
          end
        rescue StandardError => e
          puts "An error has occurred for the scraper named '#{scraper_name}': #{e}"
          return nil
        end
      end

      private

      def output_scraper
        puts "validating scraper: #{scraper_name}"
      end

      def status_ok?
        !collection_response.parsed_response.nil? && collection_response.code == 200
      end

      def validate_collections
        collections.each do |collection_name|
          collection = collection_counts.find{|collection_hash| collection_hash['collection'] == collection_name }
          if collection
            ValidateCollection.new(scraper_name, collection_name, collection['outputs'], rules, outputs, options.merge({'data' => @data})).run
          else
            puts "collection #{collection_name} is missing"
          end
        end
      end

      def output_response
        if collection_response.parsed_response.nil?
          puts "collection response is null"
        else
          puts collection_response.parsed_response['message']
        end
      end

      def collection_counts
        @collection_counts ||= collection_response.parsed_response
      end

      def collection_response
        @collection_response || AnswersEngine::Client::ScraperJobOutput.new.collections(scraper_name)
      end
    end

    class ValidateCollection
      attr_reader :scraper_name, :collection_name, :total_records, :rules, :errors, :outputs, :options

      def initialize(scraper_name, collection_name, total_records, rules, outputs, options)
        @scraper_name = scraper_name
        @collection_name = collection_name
        @total_records = total_records
        @rules = rules
        @outputs = outputs
        @data = options['data']
        @options = options
        @errors = { errored_items: [] }
      end

      def run
        output_collection
        if most_recent_finished_job
          puts "data count #{data.count}"
          if data.any?
            ValidateGroups.new(data, scraper_name, collection_name, errors).run
            ValidateRules.new(data, errors, rules).run if rules
          end
          SaveOutput.new(data.count, rules, errors, outputs_collection_name, outputs, options).run
        else
          puts "No job with status 'done' available"
        end
      end

      private

      def output_collection
        puts "Validating collection: #{collection_name}"
      end

      def most_recent_finished_job
        @most_recent_finished_job ||= begin
                                        jobs_response = AnswersEngine::Client::ScraperJob.new.all(scraper_name)
                                        if jobs_response.code == 200
                                          jobs_response.parsed_response.sort_by { |job| job['created_at'] }.reverse.find{|job| job['status'] == 'active' || job['status'] == 'done' }
                                        else
                                          nil
                                        end
                                      end
      end

      def data
        @data ||= begin
                    data = []
                    page = 1
                    while data.count < total_records
                      records = AnswersEngine::Client::JobOutput.new(per_page:500, page: page).all(most_recent_finished_job['id'], collection_name).parsed_response
                      sleep 1
                      if records
                        records.each do |record|
                          data << record
                        end
                      else
                        puts "All ScraperJobOutput request was nil. Total records: #{total_records}, data count: #{data.count}, page: #{page}"
                        break
                      end
                      page += 1
                    end
                    data
                  end
      end

      def outputs_collection_name
        @outputs_collection_name ||= "#{scraper_name}_#{collection_name}"
      end
    end
  end
end
