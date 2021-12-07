# frozen_string_literal: true

require 'readymade/response'
require 'readymade/action'

module Readymade
  class Operation < Readymade::Action
    attr_reader :form, :record, :record_params

    private

    def build_form
      @form = form_class.new(record_params, record: record)
    end

    def form_valid?
      build_form if @form.nil? && defined?(:build_form)

      form.validate
    end

    def assign_attributes
      record.assign_attributes(record_params)
    end

    def record_valid?
      return true if record.errors.none? && record.valid?

      false
    end

    def save_record
      record.save
    end

    def response(status, *args)
      Response.new(status, *args)
    end

    def success(*args)
      response(:success, *args)
    end

    def validation_fail(status = :validation_fail, args = {})
      sync_errors_to_form

      response(status, args.merge!(record: record,
                                   record_params: record_params,
                                   form: form,
                                   errors: form.errors.messages))
    end

    def fail(status = :fail, args = {})
      sync_errors_to_form

      response(status, args.merge!(record: record,
                                   record_params: record_params,
                                   form: form,
                                   errors: form&.errors&.messages.presence || record&.errors&.messages))
    end

    def form_class
      raise 'Define your own form object class in your operation'
    end

    def sync_errors_to_form
      form.sync_errors(from: record, to: form)
    end

    def sync_errors_to_record
      form.sync_errors
    end
  end
end
