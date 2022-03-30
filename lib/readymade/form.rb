# frozen_string_literal: true

require 'active_model'

module Readymade
  class Form
    include ActiveModel::Model

    attr_accessor :record, :params, :args

    PERMITTED_ATTRIBUTES = [].freeze
    REQUIRED_ATTRIBUTES = [].freeze

    def initialize(params, **args)
      @params = params
      @record = args[:record]
      @args = args
      @nested_forms = []
      @required_attributes = Array(args[:required]).presence
      @permitted_attributes = (Array(@required_attributes) + Array(args[:permitted])).presence

      parse_datetime_params

      # Slice all attributes which is not required by form
      # to omit save of unpredictable params
      @params&.slice!(*permitted_attributes) # if permitted_attributes.present?

      # dynamically creates attr accessors
      @permitted_attributes&.each do |key|
        singleton_class.class_eval do
          attr_accessor key
        end
      end

      # automatically validates all REQUIRED_ATTRIBUTES
      singleton_class.validates(*required_attributes, presence: true) if required_attributes.present?

      build_nested_forms

      super(@params)
    end

    def permitted_attributes
      @permitted_attributes ||= self.class::PERMITTED_ATTRIBUTES
    end

    def required_attributes
      @required_attributes ||= self.class::REQUIRED_ATTRIBUTES
    end

    def build_nested_forms
      nested_forms_mapping.each do |attr, form_class|
        next if params[attr].blank?

        if form_class.is_a?(Array)
          n_forms = if params[attr].is_a?(Hash)
                      # { 0 => {id: 1, name: 'my name'}, 1 => { id: 2, name: 'other name' }}
                      params[attr].map { |_i, attrs| form_class[0].new(attrs) }
                    else
                      # [{id: 1, name: 'my name'}, { id: 2, name: 'other name' }]
                      params[attr].map { |attrs| form_class[0].new(attrs) }
                    end
          @nested_forms.push(*n_forms)
          define_singleton_method("#{attr}_forms") { n_forms }
        else
          @nested_forms.push(f = form_class.new(params[attr]))
          define_singleton_method("#{attr}_form") { f }
        end
      end
    end

    def validate
      super && validate_nested(*nested_forms)
    end

    def validate_nested(*nested_forms)
      nested_forms.compact.map(&:validate).all? || sync_nested_errors(nested_forms)
    end

    # copy errors from nested forms into parent form
    def sync_nested_errors(nested_forms)
      nested_forms.each do |n_form|
        n_form.errors.each do |code, text|
          errors.add("#{n_form.humanized_name}.#{code}", text)
        end
      end

      false
    end

    # sync errors from form to record or vice-versa
    def sync_errors(from: self, to: record)
      return if [from, to].any?(&:blank?)

      if Rails.version.to_f > 6.0
        from.errors.messages.each do |key, values|
          Array.wrap(values).uniq.each do |uv|
            to.errors.add(key, uv)
          end
        end
      else
        errors = from.errors.instance_variable_get('@messages').to_h
        errors.merge!(to.errors.instance_variable_get('@messages').to_h)

        to.errors.instance_variable_set('@messages', errors)
        to.errors.messages.transform_values!(&:uniq) # Does not work with rails 6.1
      end
    rescue FrozenError => _e
    end

    def humanized_name
      self.class.name.underscore.split('/')[0]
    end

    # uses datetime_params to fix the following issue:
    # https://stackoverflow.com/questions/5073756/where-is-the-rails-method-that-converts-data-from-datetime-select-into-a-datet
    def parse_datetime_params
      datetime_params.each do |param|
        next if @params[param].present?

        # set datetime to nil if year is blank
        if @params["#{param}(1i)"].blank?
          @params[param] = nil

          next
        end

        @params[param] = DateTime.new(*(1..5).map { |i| @params["#{param}(#{i}i)"].to_i })
      end
    rescue ArgumentError
      nil
    end

    # list datetime_params in child form in order to parse datetime properly
    def datetime_params
      []
    end

    # list nested_forms in child form in order to validate them
    attr_reader :nested_forms

    # define nested forms in format { attr_name: MyFormClass }
    # use the following syntax if attribute is a collection: { attr_collection_name: [MyFormClass] }
    def nested_forms_mapping
      {}
    end

    # EXAMPLE
    # class Items::Forms::Create::Value < ::Readymade::Form
    #   PERMITTED_ATTRIBUTES = %i[vat_percent price_type item_category].freeze
    #   REQUIRED_ATTRIBUTES = %i[item_category].freeze
    #
    #   def form_options
    #     {
    #       vat_percent: Item::VAT_OPTIONS,
    #       price_type: Item.price_types.keys,
    #       item_category: args[:company].item_categories
    #     }
    #   end

    # @form = Items::Forms::Create.form_options(company: current_company)
    # f.association :item_category, collection: @form[:item_category], required: @form.required?(:item_category)

    def self.form_options(**args)
      Readymade::Form::FormOptions.new(**args.merge!(form_class: self))
    end
    class FormOptions
      attr_reader :args

      def initialize(**args)
        @args = args
        @f_class = args.delete(:form_class)
      end

      def [](key)
        to_h[key]
      end

      def to_h
        raise Readymade::Error.new('define form_options on your form') unless (f = @f_class.new({}, @args)).respond_to?(:form_options)

        f.form_options
      end

      def as_json(options = {})
        to_h.as_json(options)
      end

      def required?(attr)
        @f_class::REQUIRED_ATTRIBUTES.include?(attr.to_sym)
      end
    end
  end
end
