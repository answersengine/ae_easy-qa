require 'ae_easy/qa/helpers'
require 'ae_easy/qa/version'
require 'ae_easy/qa/validate_internal'
require 'ae_easy/qa/validate_external'
require 'ae_easy/qa/validate_rules'
require 'ae_easy/qa/validate_type'
require 'ae_easy/qa/validate_value'
require 'ae_easy/qa/validate_groups'
require 'ae_easy/qa/save_output'
require 'answersengine'
require 'time'

module AeEasy
  module Qa
    class Validator
      attr_accessor :config
      attr_reader :data, :options, :errors

      def initialize(data=nil, options={})
        load_config
        @options = options
        @data = data
      end

      def validate_internal(outputs)
        ValidateInternal.new(config, outputs).run
      end

      def validate_external(outputs, collection_name)
        ValidateExternal.new(data, config, outputs, collection_name, options).run
      end

      private

      def load_config
        self.config = YAML.load(File.open(config_path))['qa'] if File.exists?(config_path)
      end

      def config_path
        @config_path ||= File.expand_path('ae_easy.yaml', Dir.pwd)
      end
    end
  end
end
