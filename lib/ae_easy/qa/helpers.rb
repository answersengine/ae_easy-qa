module AeEasy
  module Qa
    module Helpers
      def add_errored_item(data_hash, field_to_validate, validation)
        error_name = "#{field_to_validate}_#{validation}"
        errored_item[:failures][error_name.to_sym] = 'fail'
        errored_item[:item] = data_hash if errored_item[:data].nil?
      end

      def pass_if?(if_params, data_hash)
        field_name = if_params.keys.first
        condition_hash = if_params[field_name]
        case condition_hash.keys.first
        when 'value'
          value_hash = condition_hash['value'] #Ex: {"equal"=>"A"}
          if value_hash['equal']
            data_hash[field_name] == value_hash['equal']
          elsif value_hash['regex']
            data_hash[field_name].to_s =~ Regexp.new(value_hash['regex'], true)
          elsif value_hash['less_than']
            data_hash[field_name] < value_hash['less_than']
          elsif value_hash['greater_than']
            data_hash[field_name] > value_hash['greater_than']
          else
            raise StandardError.new("The if condition '#{value_hash}' is unknown.")
          end
        end
      end
    end
  end
end
