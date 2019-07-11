module AeEasy
  module Qa
    class ValidateExternal
      attr_reader :data, :errors, :rules, :outputs, :collection_name

      def initialize(data, config, outputs, collection_name)
        @data = data
        @rules = config['individual_validations'] if config
        @outputs = outputs
        @collection_name = collection_name
        @errors = { errored_items: [] }
      end

      def run
        begin
          if data.any?
            ValidateGroups.new(data, collection_name, errors).run
            ValidateRules.new(data, errors, rules).run if rules
          end
          SaveOutput.new(data.count, rules, errors, collection_name, outputs).run
          return errors
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end
    end
  end
end
