module AeEasy
  module Qa
    class ValidateGroups
      attr_reader :data, :collection_name, :errors

      def initialize(data, collection_name, errors)
        @data = data
        @collection_name = collection_name
        @errors = errors
      end

      def run
        if group_validations_present?
          load_module
          include_module
          call_validation_methods
        end
      end

      private

      def fail_validation(name)
        errors[name.to_sym] = 'fail'
      end

      def load_module
        load group_validations_path
      end

      def include_module
        self.class.send(:include, GroupValidations)
      end

      def call_validation_methods
        GroupValidations.public_instance_methods.each do |method|
          self.send(method)
        end
      end

      def group_validations_present?
        File.exists?(group_validations_path)
      end

      def group_validations_path
        @group_validations_path ||= File.expand_path('group_validations.rb', Dir.pwd)
      end
    end
  end
end
