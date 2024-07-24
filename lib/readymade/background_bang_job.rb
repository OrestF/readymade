# frozen_string_literal: true

require 'active_job' unless defined?(::ActiveJob)

module Readymade
  class BackgroundBangJob < ::ActiveJob::Base
    queue_as { arguments[0].fetch(:queue_as, :default) }

    def perform(**args)
      args.delete(:class_name).to_s.constantize.send(:call!, **args)
    end
  end
end
