require 'ae_easy/qa/helpers'
require 'ae_easy/qa/version'
require 'ae_easy/qa/validate_internal'
require 'ae_easy/qa/validate_external'
require 'ae_easy/qa/validate_rules'
require 'ae_easy/qa/validate_type'
require 'ae_easy/qa/validate_value'
require 'ae_easy/qa/validate_groups'
require 'answersengine'
require 'time'

module AeEasy
  module Qa
    class Validator
      attr_accessor :config
      attr_reader :data, :errors

      def initialize(data=nil, options={})
        load_config
        @data = data
        @errors = { errored_items: [] }
      end

      def validate_internal
        ValidateInternal.new(config).run
      end

      def validate_external
        ValidateExternal.new(data, errors, config).run
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
