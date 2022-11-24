# frozen_string_literal: true

def to_api_file(file)
  { base64: Base64.encode64(file.read), filename: file.original_filename }
end
