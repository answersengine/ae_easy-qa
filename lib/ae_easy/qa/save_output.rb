module AeEasy
  module Qa
    class SaveOutput
      attr_reader :total_items, :rules, :errors, :collection_name,
                  :outputs, :summary, :error_totals, :fields_to_ignore

      def initialize(total_items, rules, errors, collection_name, outputs)
        @total_items = total_items
        @rules = rules
        @errors = errors
        @collection_name = collection_name
        @outputs = outputs
        @summary = Hash.new(0)
        @error_totals = {}
        @fields_to_ignore = []
      end

      def run
        gather_threshold_totals
        gather_fields_to_ignore
        save_group_errors
        save_errors
        save_summary
      end

      private

      def gather_threshold_totals
        rules.each{|field_to_validate, options|
          if options['threshold']
            error_total = errors[:errored_items].inject(0){|total, errored_item|
              failed_fields = errored_item[:failures].collect{|failure|
                extract_field(failure.keys.first)
              }.uniq
              total + 1 if failed_fields.include?(field_to_validate)
            }
            error_totals[field_to_validate] = error_total
          end
        }
      end

      def gather_fields_to_ignore
        rules.each{|field_to_validate, options|
          if options['threshold']
            total_errors = error_totals[field_to_validate]
            success_ratio = (total_items - total_errors).to_f / total_items
            fields_to_ignore.push(field_to_validate) if success_ratio > options['threshold']
          end
        }
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
          remove_threshold_failures(errored_item) if fields_to_ignore.any?
          errored_item[:failures].each do |failure|
            key = "#{failure.keys.first.to_s}_#{failure.values.first.to_s}"
            summary[key] += 1
          end
          errored_item['_collection'] = collection_name
          outputs << errored_item if errored_item[:failures].any?
        end
      end

      def remove_threshold_failures(errored_item)
        errored_item[:failures].delete_if{|failure_h|
          field_name = extract_field(failure_h.keys.first)
          fields_to_ignore.include?(field_name)
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
