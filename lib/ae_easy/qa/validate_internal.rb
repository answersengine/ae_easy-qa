module AeEasy
  module Qa
    class ValidateInternal
      attr_reader :scrapers, :rules, :outputs

      def initialize(config, outputs)
        @scrapers = config['scrapers']
        @rules = config['individual_validations']
        @outputs = outputs
      end

      def run
        begin
          scrapers.each do |scraper_name, collections|
            ValidateScraper.new(scraper_name, collections, rules, outputs).run
          end
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end
    end

    class ValidateScraper
      attr_reader :scraper_name, :collections, :rules, :outputs

      def initialize(scraper_name, collections, rules, outputs)
        @scraper_name = scraper_name
        @collections = collections
        @rules = rules
        @outputs = outputs
      end

      def run
        output_scraper
        if status_ok?
          validate_collections if collections && collections.any?
        else
          output_response
          return nil
        end
      end

      private

      def output_scraper
        puts "Validating scraper: #{scraper_name}"
      end

      def status_ok?
        collection_counts.code == 200
      end

      def validate_collections
        collections.each do |collection_name|
          ValidateCollection.new(scraper_name, collection_name, total_records(collection_name), rules, outputs).run
        end
      end

      def output_response
        puts collection_counts.parsed_response['message']
      end

      def total_records(collection_name)
        collection_counts.find{|collection_hash| collection_hash['collection'] == collection_name }['outputs']
      end

      def collection_counts
        @collection_counts ||= AnswersEngine::Client::ScraperJobOutput.new.collections(scraper_name)
      end
    end

    class ValidateCollection
      attr_reader :scraper_name, :collection_name, :total_records, :rules, :errors, :outputs

      def initialize(scraper_name, collection_name, total_records, rules, outputs)
        @scraper_name = scraper_name
        @collection_name = collection_name
        @total_records = total_records
        @rules = rules
        @outputs = outputs
        @errors = { errored_items: [] }
      end

      def run
        output_collection
        if data.any?
          ValidateGroups.new(data, scraper_name, collection_name, errors).run
          ValidateRules.new(data, errors, rules).run if rules
        end
        SaveOutput.new(data.count, rules, errors, outputs_collection_name, outputs).run
      end

      private

      def output_collection
        puts "Validating collection: #{collection_name}"
      end

      def outputs_collection_name
        @outputs_collection_name ||= "#{scraper_name}_#{collection_name}"
      end

      def data
        @data ||= begin
                    data = []
                    page = 1
                    while data.count < total_records
                      records = AnswersEngine::Client::ScraperJobOutput.new(per_page:500, page: page).all(scraper_name, collection_name).parsed_response
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
    end
  end
end
