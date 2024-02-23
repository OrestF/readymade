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

        def send_chain_with_or(methods, scope = self)
          return scope if methods.blank?

          conditions = []
          if methods.respond_to?(:keys)
            methods.each do |scope_name, argument|
              conditions << send(scope_name, argument)
            end
          else
            methods.each do |scope_name|
              conditions << send(scope_name)
            end
          end

          where(id: conditions.inject(:or).select(:id))
        end

        def filter_collection(filtering_params, chain_with: :and)
          filtering_params.permit! if filtering_params.respond_to?(:permit)

          regular_params = filtering_params.select { |_key, value| value.present? }.to_h
          custom_params = filtering_params.to_h.select { |_key, value| value.is_a?(String) && value.start_with?('without_') }.values

          if chain_with == :and
            send_chain(regular_params, send_chain(custom_params)).all
          elsif chain_with.to_sym == :or
            send_chain_with_or(regular_params, send_chain_with_or(custom_params)).all
          else
            none
          end
        end
      end
    end
  end
end
