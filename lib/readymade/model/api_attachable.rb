require 'active_support/concern'

module Readymade
  module Model
    module ApiAttachable
      extend ActiveSupport::Concern
      # must be included after has_one_attached, has_many_attached declaration
      # api_file = {
      #   base64: 'iVBORw0KGgoAAA....',
      #   filename: 'my_avatar.png'
      # }
      # record.avatar = api_file 🎉

      included do
        has_one_attached_reflections.map(&:name).each do |attachment_method_name|
          define_method("#{attachment_method_name}=") do |attachment_file|
            attachment_file = api_attachment_to_uploaded(attachment_file) if api_attachable_format?(attachment_file)
            super(attachment_file)
          end
        end

        has_many_attached_reflections.map(&:name).each do |attachment_method_name|
          define_method("#{attachment_method_name}=") do |attachment_file|
            attachment_file = Array.wrap(attachment_file).map do |af|
              api_attachable_format?(af) ? api_attachment_to_uploaded(af) : af
            end
            super(attachment_file)
          end
        end
      end

      class_methods do
        # rubocop:disable Naming/PredicateName
        def has_one_attached_reflections
          reflect_on_all_attachments.filter { |association| association.instance_of?(ActiveStorage::Reflection::HasOneAttachedReflection) }
        end

        def has_many_attached_reflections
          reflect_on_all_attachments.filter { |association| association.instance_of?(ActiveStorage::Reflection::HasManyAttachedReflection) }
        end
        # rubocop:enable Naming/PredicateName
      end

      def api_attachable_format?(attachment_file)
        attachment_file.respond_to?(:key?) && attachment_file.key?('base64') && attachment_file.key?('filename')
      end

      def api_attachment_to_uploaded(attachment_file)
        ActionDispatch::Http::UploadedFile.new(
          tempfile: Tempfile.new(attachment_file[:filename]).tap do |tf|
            tf.binmode
            tf.write(Base64.decode64(attachment_file[:base64].split('base64,')[-1]))
          end,
          filename: attachment_file[:filename],
          type: Mime::Type.lookup_by_extension(File.extname(attachment_file[:filename])[1..]).to_s
        )
      end
    end
  end
end
