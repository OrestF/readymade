# frozen_string_literal: true

require 'active_job' unless defined?(::ActiveJob)

module Readymade
  class BackgroundJob < ::ActiveJob::Base
    # queue_as :default

    def perform(**args)
      args.delete(:class_name).to_s.constantize.send(:call, **args)
    end
  end
end
