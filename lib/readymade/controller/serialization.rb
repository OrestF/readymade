require 'active_support/concern'

module Readymade
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def record_response(record, *args)
        options = args.extract_options!
        return render_json({}, :not_found) if record.nil?

        hash = serialize_record(record, options)

        status = if record.errors.none?
                   options[:status] || :ok
                 else
                   hash[:errors] = record.errors.messages
                   :bad_request
                 end
        render_json(hash, status)
      end

      def collection_response(collection, *args)
        options = args.extract_options!

        render_json(
          {
            (options.delete(:root).presence || :items) => serialize_collection(paginate(collection, options), options),
            count: collection.count
          },
          options[:status] || :ok
        )
      end

      def render_json(message, status)
        render json: message, status: status
      end

      def serialize_collection(collection, options = {})
        serializer = options.delete(:serializer) || "#{collection.klass.name}Serializer".constantize
        serializer.render_as_hash(collection, options)
      end

      def serialize_record(record, options = {})
        serializer = options.delete(:serializer) || "#{record.class.name}Serializer".constantize
        serializer.render_as_hash(record, { root: :data }.merge!(options))
      end

      def operation_response(response_obj, options = {})
        message, status = case response_obj.status.to_sym
                          when :success, :ok
                            [
                              if response_obj.data[:record].present?
                                serialize_record(response_obj.data[:record],
                                                 options)
                              else
                                {}
                              end,
                              :ok
                            ]
                          when :validation_fail, :bad_request
                            [{ errors: response_obj.data[:errors] }, :bad_request]
                          else
                            [response_obj.status.to_sym, {}]
                          end
        render_json(message, status)
      end
    end
  end
end
