module AeEasy
  module Qa
    class ValidateValue < ValidateRules
      attr_reader :data_hash, :field_to_validate, :params

      def initialize(data_hash, field_to_validate, params, errored_item)
        @data_hash = data_hash
        @field_to_validate = field_to_validate
        @params = params
        @errored_item = errored_item
      end

      def run
        condition_exists? ? handle_conditions : main_value_check
      end

      private

      def condition_exists?
        !params['if'].nil?
      end

      def handle_conditions
        field_name = params['if'].keys.first
        condition_hash = params['if'][field_name]
        case condition_hash.keys.first
        when 'value'
          if(data_hash[field_name] == condition_hash.values.first)
            main_value_check
          end
        end
      end

      def main_value_check
        if params['equal']
          if equal_with_operators?
            equal_with_operators
          else
            add_errored_item(data_hash, field_to_validate, 'value') if(data_hash[field_to_validate] != params['equal'])
          end
        elsif params['less_than']
          add_errored_item(data_hash, field_to_validate, 'value') if !(data_hash[field_to_validate] < params['less_than'])
        elsif params['greater_than']
          add_errored_item(data_hash, field_to_validate, 'value') if !(data_hash[field_to_validate] > params['greater_than'])
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
