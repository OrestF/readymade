require 'active_support/concern'

module Readymade
  module Model
    module ValidatableEnum
      extend ActiveSupport::Concern

      class_methods do
        def validatable_enum(*enums_to_fix)
          enums_to_fix.each do |enum_name|
            define_method(:"#{enum_name}=") do |value|
              super(value)
            rescue StandardError
              instance_variable_set(:"@__bad_#{enum_name}", value)
              super(nil)
            end

            validates enum_name, inclusion: {
              in: send(enum_name.to_s.pluralize).keys,
              message: lambda { |record, error|
                val = record.instance_variable_get(:"@__bad_#{enum_name}")
                return "#{error[:attribute]} is required" if val.nil?

                "#{val.inspect} is not a valid #{error[:attribute]}"
              }
            }
          end
        end
      end
    end
  end
end
