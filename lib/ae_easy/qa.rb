require 'ae_easy/qa/version'
require 'ae_easy/qa/validate_rules'
require 'ae_easy/qa/validate_type'
require 'ae_easy/qa/validate_value'
require 'answersengine'

module AeEasy
  module Qa
    class Validate
      attr_accessor :rules
      attr_reader :data, :errors

      def initialize(data, options={})
        load_rules
        @data = data
        @errors = { errored_items: [] }
      end

      def run
        begin
          ValidateRules.new(data, errors, rules).run if rules
          return errors
        rescue StandardError => e
          puts "An error has occurred: #{e}"
          return nil
        end
      end

      def add_validation(method)
        instance_eval(&method)
      end

      def fail_validation
        self.errors[@name.to_sym] = 'fail'
      end

      private

      def load_rules
        self.rules = YAML.load(File.open(config_path))['qa'] if File.exists?(config_path)
      end

      def config_path
        @config_path ||= File.expand_path('ae_easy.yaml', Dir.pwd)
      end
    end
  end
end
