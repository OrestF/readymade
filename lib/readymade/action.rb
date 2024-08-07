# frozen_string_literal: true

require 'readymade/response'
require 'readymade/background_job'
require 'readymade/background_bang_job'

module Readymade
  class Action
    class NonKeywordArgumentsError < StandardError; end
    class UnSuccessError < StandardError; end

    def self.call(*args, &block)
      new(*args, &block).call
    end

    def self.call!(*args, &block)
      new(*args, &block).call!.then do |res|
        return res if res.try(:success?) || res.try(:consider_success?)

        raise UnSuccessError.new(res.humanized_errors)
      end
    end

    def self.call_async(*args, &block)
      new(*args, &block).call_async
    end

    def self.call_async!(*args, &block)
      new(*args, &block).call_async!
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

    def call!
      call
    end

    def call_async
      ::Readymade::BackgroundJob.perform_later(class_name: self.class.name, **args)
    end

    def call_async!
      ::Readymade::BackgroundBangJob.perform_later(class_name: self.class.name, **args)
    end

    def response(status, *args)
      Response.new(status, *args)
    end
  end
end
