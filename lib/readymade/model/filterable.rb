# frozen_string_literal: true

require 'active_support/concern'

module Readymade
  module Model
    module Filterable
      extend ActiveSupport::Concern

      module ClassMethods
        def send_chain(methods, scope = self)
          return scope if methods.blank?

          if methods.respond_to?(:keys)
            methods.inject(scope) do |obj, (method, value)|
              obj.send(method, value)
            end
          else
            methods.inject(scope) do |obj, method|
              obj.send(method)
            end
          end
        end

        def filter_collection(filtering_params)
          filtering_params.permit! if filtering_params.respond_to?(:permit)

          regular_params = filtering_params.select { |_key, value| value.present? }.to_h
          custom_params = filtering_params.to_h.select do |_key, value|
            value.is_a?(String) && value.start_with?('without_')
          end.values

          send_chain(regular_params, send_chain(custom_params)).distinct
        end
      end
    end
  end
end
