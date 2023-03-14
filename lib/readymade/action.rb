# frozen_string_literal: true

require 'readymade/response'
require 'readymade/background_job'

module Readymade
  class Action
    class NonKeywordArgumentsError < StandardError; end

    def self.call(*args, &block)
      new(*args, &block).call
    end

    def self.call_async(*args, &block)
      new(*args, &block).call_async
    end

    attr_reader :args, :data

    def initialize(args = {})
      raise NonKeywordArgumentsError if args.present? && !args.is_a?(Hash)

      @args = @data = args
      @args.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def call; end

    def call_async
      ::Readymade::BackgroundJob.perform_later(class_name: self.class.name, **args)
    end

    def response(status, *args)
      Response.new(status, *args)
    end
  end
end
