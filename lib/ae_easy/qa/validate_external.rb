module AeEasy
  module Qa
    class ValidateExternal
      attr_reader :data, :errors, :config

      def initialize(data, errors, config)
        @data = data
        @errors = errors
        @config = config
      end

      def run
        begin
          ValidateGroups.new(data, errors).run
          ValidateRules.new(data, errors, config['individual_validations']).run if config
          return errors
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end
    end
  end
end
