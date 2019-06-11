module AeEasy
  module Qa
    module Helpers
      def add_errored_item(data_hash, field_to_validate, validation)
        error_name = "#{field_to_validate}_#{validation}"
        errored_item[:failures].push({ error_name.to_sym => 'fail' })
        errored_item[:item] = data_hash if errored_item[:data].nil?
      end
    end
  end
end
