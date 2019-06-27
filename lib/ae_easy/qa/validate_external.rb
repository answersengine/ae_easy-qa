module AeEasy
  module Qa
    class ValidateExternal
      attr_reader :data, :errors, :config, :outputs, :collection_name

      def initialize(data, config, outputs, collection_name)
        @data = data
        @config = config
        @outputs = outputs
        @collection_name = collection_name
        @errors = { errored_items: [] }
      end

      def run
        begin
          ValidateGroups.new(data, collection_name, errors).run
          ValidateRules.new(data, errors, config['individual_validations']).run if config
          SaveOutput.new(errors, collection_name, outputs).run
          return errors
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end
    end
  end
end
