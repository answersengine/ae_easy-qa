module AeEasy
  module Qa
    class SaveOutput
      attr_reader :errors, :collection_name, :outputs, :summary

      def initialize(errors, collection_name, outputs)
        @errors = errors
        @collection_name = collection_name
        @outputs = outputs
        @summary = Hash.new(0)
      end

      def run
        save_group_errors
        save_errors
        save_summary
      end

      private

      def save_group_errors
        errors.each{|error_name, output_hash|
          if error_name != :errored_items
            output_hash['_collection'] = collection_name
            outputs << output_hash
            error_name = output_hash[:failure]
            summary[error_name] += 1
          end
        }
      end

      def save_errors
        errors[:errored_items].each do |errored_item|
          errored_item[:failures].each do |failure|
            key = "#{failure.keys.first.to_s}_#{failure.values.first.to_s}"
            summary[key] += 1
          end
          errored_item['_collection'] = collection_name
          outputs << errored_item
        end
      end

      def save_summary
        if summary.any?
          summary['_collection'] = "#{collection_name}_summary"
          outputs << summary
        end
      end
    end
  end
end
