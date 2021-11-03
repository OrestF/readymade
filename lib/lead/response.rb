# frozen_string_literal: true

module Lead
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

      define_singleton_method("#{status}?") do
        true
      end
    end

    def errors
      args[:errors].presence || {}
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
