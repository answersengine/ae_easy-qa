module AeEasy
  module Qa
    class ValidateInternal
      attr_reader :scrapers, :rules

      def initialize(config)
        @scrapers = config['scrapers']
        @rules = config['individual_validations']
      end

      def run
        begin
          scrapers.each do |scraper_name, collections|
            ValidateScraper.new(scraper_name, collections, rules).run
          end
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end
    end

    class ValidateScraper
      attr_reader :scraper_name, :collections, :rules

      def initialize(scraper_name, collections, rules)
        @scraper_name = scraper_name
        @collections = collections
        @rules = rules
      end

      def run
        collections.each do |collection_name|
          ValidateCollection.new(scraper_name, collection_name, total_records(collection_name), rules).run
        end
      end

      private

      def total_records(collection_name)
        collection_counts.find{|collection_hash| collection_hash['collection'] == collection_name }['count']
      end

      def collection_counts
        @collection_counts ||= AnswersEngine::Client::ScraperJobOutput.new.collections(scraper_name)
      end
    end

    class ValidateCollection
      attr_reader :scraper_name, :collection_name, :total_records, :rules, :errors

      def initialize(scraper_name, collection_name, total_records, rules)
        @scraper_name = scraper_name
        @collection_name = collection_name
        @total_records = total_records
        @rules = rules
        @errors = { errored_items: [] }
      end

      def run
        ValidateGroups.new(data, errors).run
        #could create the errors hash inside ValidateRules?
        #errors = ValidateRules.new(data, config).run
        ValidateRules.new(data, errors, rules).run
        #should have a class that saves the output and the summary output
        #SaveOutput.new(errors, output_collection_name).run
      end

      private

      def output_collection_name
        @output_collection_name ||= "#{scraper_name}_#{collection_name}"
      end

      def data
        @data ||= begin
                    data = []
                    page = 1
                    while data.count < total_records
                      records = AnswersEngine::Client::ScraperJobOutput.new(per_page:500, page: page).all(scraper_name, collection_name).parsed_response
                      records.each do |record|
                        data << record
                      end
                      page += 1
                    end
                    data
                  end
      end

    end
  end
end
