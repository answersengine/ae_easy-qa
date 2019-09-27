module AeEasy
  module Qa
    class ValidateValue
      include Helpers

      attr_reader :data_hash, :field_to_validate, :params, :errored_item

      def initialize(data_hash, field_to_validate, params, errored_item)
        @data_hash = data_hash
        @field_to_validate = field_to_validate
        @params = params
        @errored_item = errored_item
      end

      def run
        if_exists? ? handle_if : main_value_check
      end

      private

      def if_exists?
        !params['if'].nil?
      end

      def handle_if
        main_value_check if pass_if?(params['if'], data_hash)
      end

      def main_value_check
        if params['equal']
          if equal_with_operators?
            equal_with_operators
          else
            add_errored_item(data_hash, field_to_validate, 'value') if (data_hash[field_to_validate] != params['equal'])
          end
        elsif params['regex']
          add_errored_item(data_hash, field_to_validate, 'value') if (data_hash[field_to_validate].to_s !~ Regexp.new(params['regex'], true))
        elsif params['less_than']
          add_errored_item(data_hash, field_to_validate, 'value') if !(data_hash[field_to_validate].to_i < params['less_than'].to_i)
        elsif params['greater_than']
          add_errored_item(data_hash, field_to_validate, 'value') if !(data_hash[field_to_validate].to_i > params['greater_than'].to_i)
        else
          unknown_value_error
        end
      end

      def equal_with_operators
        case equal_operator
        when 'or'
          add_errored_item(data_hash, field_to_validate, 'value') if !or_statment
        end
      end

      def or_statment
        eval or_vals.map{|val| "data_hash[field_to_validate] == #{val}" }.join(' || ')
      end

      def equal_with_operators?
        params['equal'].class == Hash
      end

      def equal_operator
        params['equal'].keys.first
      end

      def or_vals
        params['equal']['or']
      end

      def unknown_value_error
        raise StandardError.new("The value rule '#{params}' is unknown.")
      end
    end
  end
end
