module AeEasy
  module Qa
    class ValidateRules
      include Helpers

      attr_reader :data, :errors, :rules
      attr_accessor :errored_item

      def initialize(data, errors, rules)
        @data = data
        @errors = errors
        @rules = rules
      end

      def run
        handle_rules
      end

      private

      def handle_rules
        data.each do |data_hash|
          reset_errored_item
          rules.each{|field_to_validate, options|
            if passes_required_check?(options, data_hash, field_to_validate)
              options.each{|validation, value|
                case validation
                when 'type'
                  ValidateType.new(data_hash, field_to_validate, value, rules, errored_item).run if options['required']
                when 'value'
                  ValidateValue.new(data_hash, field_to_validate, value, errored_item).run if options['required']
                when 'length'
                  validate_length(data_hash, field_to_validate, value) if options['required']
                when /required|threshold/
                  nil
                else
                  unknown_validation_error(validation) if validation !~ /format/
                end
              }
            end
          }
          errors[:errored_items].push(errored_item) if errored_item && !errored_item[:failures].empty?
        end
      end

      def passes_required_check?(options, data_hash, field_to_validate)
        if options['required'] == true && fails_required_check?(data_hash, field_to_validate)
          add_errored_item(data_hash, field_to_validate, 'required')
          false
        else
          true
        end
      end

      def fails_required_check?(data_hash, field_to_validate)
        data_hash[field_to_validate].nil? || (data_hash[field_to_validate].class == String && data_hash[field_to_validate].empty?)
      end

      def validate_length(data_hash, field_to_validate, length)
        add_errored_item(data_hash, field_to_validate, 'length') if data_hash[field_to_validate].to_s.length != length
      end

      def reset_errored_item
        self.errored_item = { failures: [] }
      end

      def unknown_validation_error(validation)
        raise StandardError.new("The validation '#{validation}' is unknown.")
      end
    end
  end
end
