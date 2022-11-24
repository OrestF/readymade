# frozen_string_literal: true

require 'rails/generators/named_base'

module Readymade
  module Generators
    class OperationGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)
      desc 'Generates a readymade operation and form.'

      class_option :record_name, type: :string, aliases: '-r', required: true
      class_option :operation_name, type: :array, aliases: '-t', required: true

      def generate_operation
        template "operations/#{operation_type}.rb", operation_path
      end

      def generate_form
        template 'form.rb', form_path
      end

      private

      def operation_type
        %w[create update destroy].include?(options['operation_name']) ? options['operation_name'] : 'update'
      end

      def operation_path
        "#{Rails.root}/business/#{options['record_name'].pluralize}/operations/#{options['operation_name']}.rb"
      end

      def form_path
        "#{Rails.root}/business/#{options['record_name'].pluralize}/forms/#{options['operation_name']}.rb"
      end
    end
  end
end
