# frozen_string_literal: true

require 'rails/generators/named_base'

module Readymade
  module Generators
    class ActionGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)
      desc 'Generates a readymade action.'

      class_option :record_name, type: :string, aliases: '-r', required: true
      class_option :action_name, type: :string, aliases: '-t', required: true

      def generate_action
        template 'action.rb', action_path
      end

      private

      def action_path
        "#{Rails.root}/business/#{options['record_name'].pluralize}/actions/#{options['action_name']}.rb"
      end
    end
  end
end
