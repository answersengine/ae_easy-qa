module AeEasy
  module Qa
    class ValidateType
      include Helpers

      attr_reader :data_hash, :field_to_validate, :desired_type, :rules, :errored_item

      def initialize(data_hash, field_to_validate, desired_type, rules, errored_item)
        @data_hash = data_hash
        @field_to_validate = field_to_validate
        @desired_type = desired_type
        @rules = rules
        @errored_item = errored_item
      end

      def run
        handle_types
      end

      private

      def handle_types
        case desired_type
        when 'String'
          add_errored_item(data_hash, field_to_validate, 'type') if data_hash[field_to_validate].class != String
        when 'Integer'
          add_errored_item(data_hash, field_to_validate, 'type') unless data_hash[field_to_validate].class == Fixnum || data_hash[field_to_validate].to_s.strip =~ /\A\d+(\.\d+)?\z/
        when 'Float'
          add_errored_item(data_hash, field_to_validate, 'type') unless data_hash[field_to_validate].class == Float || data_hash[field_to_validate].to_s.strip =~ /\A\d+(\.\d+)?\z/
        when 'Date'
          validate_date_type
        when 'Url'
          add_errored_item(data_hash, field_to_validate, 'type') if data_hash[field_to_validate] !~ /^(http|https):\/\//
        else
          unknown_type_error(desired_type)
        end
      end

      def validate_date_type
        format = rules[field_to_validate]['format']
        missing_date_format_error if format.nil?
        date_str = data_hash[field_to_validate]
        begin
          date = Time.strptime(date_str, format.gsub('%-m', '%m').gsub('%-d', '%d'))
          add_errored_item(data_hash, field_to_validate, 'type') if date.strftime(format) != date_str
        rescue ArgumentError => e
          if e.to_s =~ /^invalid strptime format/
            add_errored_item(data_hash, field_to_validate, 'type')
          else
            raise StandardError.new(e.to_s)
          end
        end
      end

      def unknown_type_error(desired_type)
        raise StandardError.new("The validation type '#{desired_type}' is unknown.")
      end

      def missing_date_format_error
        raise StandardError.new("Date validation is missing a format.")
      end
    end
  end
end
