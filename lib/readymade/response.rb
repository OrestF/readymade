# frozen_string_literal: true

module Readymade
  class Response
    class NonKeywordArgumentsError < StandardError; end

    DEFAULT_STATUSES = %i[success fail].freeze

    DEFAULT_STATUSES.each do |ds|
      define_method("#{ds}?") do
        ds.to_s == status
      end
    end

    attr_reader :status, :args, :data

    def initialize(status, *args)
      @status = status.to_s

      raise NonKeywordArgumentsError if args.present? && !args[0].is_a?(Hash)

      @args = @data = args[0]
      @consider_success = @args.delete(:consider_success) if @args.present?

      define_singleton_method("#{status}?") do
        true
      end
    end

    def errors
      return {} unless args.is_a?(Hash)

      args[:errors].presence || {}
    end

    def humanized_errors
      humanize_errors(errors)
    end

    def humanize_errors(errors)
      if errors.is_a?(ActiveModel::Errors)
        errors.full_messages.join('. ')
      else
        errors.map { |k, values| "#{k.to_s.humanize}: #{values.join(', ')}" }.join('. ')
      end
    end

    def consider_success?
      @consider_success
    end

    def method_missing(method_name, *args, &block)
      return false if method_name.to_s.end_with?('?')

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?('?') || super
    end
  end
end
