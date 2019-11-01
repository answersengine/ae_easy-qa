module AeEasy
  module Qa
    class SaveOutput
      attr_reader :total_items, :rules, :errors, :collection_name,
                  :outputs, :summary, :error_totals, :fields_to_ignore,
                  :specific_validations_to_ignore, :options

      def initialize(total_items, rules, errors, collection_name, outputs, options)
        @total_items = total_items
        @rules = rules
        @errors = errors
        @collection_name = collection_name
        @outputs = outputs
        @options = options
        @summary = Hash.new(0)
        @error_totals = {}
        @fields_to_ignore = []
        @specific_validations_to_ignore = []
      end

      def run
        gather_threshold_totals
        gather_validations_to_ignore
        save_group_errors
        save_errors
        save_summary
      end

      private

      #thresholds are a setting where you can ignore errors if they are under a specific error rate
      def gather_threshold_totals
        rules.each{|field_to_validate, field_options|
          field_threshold = return_threshold(field_to_validate, field_options)
          if field_threshold
            gather_field_threshold_totals(field_to_validate, field_options)
          else
            gather_specific_validation_totals(field_to_validate, field_options)
          end
        }
      end

      def gather_field_threshold_totals(field_to_validate, field_options)
        error_total = errors[:errored_items].inject(0){|total, errored_item|
          failed_fields = errored_item[:failures].keys.collect{|failure_key|
            extract_field(failure_key)
          }.uniq
          total += 1 if failed_fields.include?(field_to_validate)
          total
        }
        error_totals[field_to_validate] = error_total
      end

      def gather_specific_validation_totals(field_to_validate, field_options)
        field_options.each do |validation|
          potential_failure_name = "#{field_to_validate}_#{validation[0]}_fail"
          if options['thresholds'] && options['thresholds'][potential_failure_name]
            error_total = errors[:errored_items].inject(0){|total, errored_item|
              failed_validations = errored_item[:failures].keys.collect{|failure_key|
                "#{failure_key}_fail"
              }
              total += 1 if failed_validations.include?(potential_failure_name)
              total
            }
            error_totals[potential_failure_name] = error_total
          end
        end
      end

      def gather_validations_to_ignore
        rules.each{|field_to_validate, field_options|
          field_threshold = return_threshold(field_to_validate, field_options)
          if field_threshold
            gather_fields_to_ignore(field_to_validate, field_threshold)
          else
            gather_specific_validations_to_ignore(field_to_validate, field_options)
          end
        }
      end

      def gather_fields_to_ignore(field_to_validate, field_threshold)
        total_errors = error_totals[field_to_validate]
        if total_errors
          success_ratio = (total_items - total_errors).to_f / total_items
          if success_ratio > field_threshold.to_f
            puts "Ignoring #{field_to_validate}"
            fields_to_ignore.push(field_to_validate)
          end
        end
      end

      def gather_specific_validations_to_ignore(field_to_validate, field_options)
        field_options.each do |validation|
          potential_failure_name = "#{field_to_validate}_#{validation[0]}_fail"
          total_errors = error_totals[potential_failure_name]
          if total_errors
            specific_validation_threshold = options['thresholds'][potential_failure_name].to_f
            success_ratio = (total_items - total_errors).to_f / total_items
            if success_ratio > specific_validation_threshold || (specific_validation_threshold == 0.0 && success_ratio == 0.0)
              puts "Ignoring #{potential_failure_name}"
              specific_validations_to_ignore.push(potential_failure_name)
            end
          end
        end
      end

      def return_threshold(field_to_validate, field_options)
        if options['thresholds']
          options['thresholds'][field_to_validate]
        else
          field_options['threshold'] || options['threshold']
        end
      end

      def save_group_errors
        errors.each{|error_name, output_hash|
          if error_name != :errored_items
            error_name = output_hash.delete(:failure)
            summary["#{error_name}_fail"] = output_hash
          end
        }
      end

      def save_errors
        errors[:errored_items].each do |errored_item|
          remove_threshold_failures(errored_item) if fields_to_ignore.any? || specific_validations_to_ignore.any?
          errored_item[:failures].each do |error_key, value|
            key = "#{error_key.to_s}_#{value.to_s}"
            summary[key] += 1
          end
          errored_item['_collection'] = collection_name
          outputs << errored_item if errored_item[:failures].any?
        end
      end

      def remove_threshold_failures(errored_item)
        errored_item[:failures].delete_if{|error_name, fail|
          specific_validation_name = "#{error_name}_fail"
          field_name = extract_field(error_name)
          fields_to_ignore.include?(field_name) || specific_validations_to_ignore.include?(specific_validation_name)
        }
      end

      def save_summary
        summary['pass'] = 'true' if summary.empty?
        summary['_collection'] = "#{collection_name}_summary"
        summary['total_items'] = total_items
        outputs << summary
      end

      def extract_field(field_sym)
        a = field_sym.to_s.split('_')
        a.pop
        a.join('_')
      end
    end
  end
end
