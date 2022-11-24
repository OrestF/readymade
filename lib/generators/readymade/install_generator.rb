# frozen_string_literal: true

require 'rails/generators/named_base'

module Readymade
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates/infrastructure', __dir__)
      desc 'Generates a readymade infrastructure.'

      def add_config
        %w[business infrastructure].each do |name|
          # Force is required because null: false already exists in the file
          inject_into_class('config/application.rb', 'Application', force: true) do
            "\t\tconfig.paths.add '#{name}', eager_load: true\n"
          end
        end
      end

      def generate_infrastructure
        %i[Action InstantForm Response Operation Form].each do |component|
          "base_#{component.to_s.underscore}.rb".then do |template_name|
            template template_name, "#{Rails.root}/infrastructure/#{template_name}"
          end
        end
      end
    end
  end
end
