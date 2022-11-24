# frozen_string_literal: true

require 'rails/generators/named_base'

module Readymade
  module Generators
    class FormGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)
      desc 'Generates a readymade form.'

      class_option :record_name, type: :string, aliases: '-r', required: true
      class_option :form_name, type: :string, aliases: '-t', required: true

      def generate_form
        template 'form.rb', form_path
      end

      private

      def form_path
        "#{Rails.root}/business/#{options['record_name'].pluralize}/forms/#{options['form_name']}.rb"
      end
    end
  end
end
