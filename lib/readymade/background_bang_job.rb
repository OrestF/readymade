# frozen_string_literal: true

require 'active_job' unless defined?(::ActiveJob)

module Readymade
  class BackgroundBangJob < ::Readymade::BackgroundJob
    def perform(**args)
      args.delete(:class_name).to_s.constantize.send(:call!, **args)
    end
  end
end
