# frozen_string_literal: true

class Explicit::Type::File < Explicit::Type
  attr_reader :max_size, :content_types

  FILE_CLASSES = [
    ActionDispatch::Http::UploadedFile,
    Rack::Test::UploadedFile
  ].freeze

  def initialize(max_size: nil, content_types: nil)
    @max_size = max_size
    @content_types = Array(content_types)
  end

  def validate(value)
    if !FILE_CLASSES.any? { |klass| value.is_a?(klass) }
      return [:error, error_i18n("file")] 
    end

    if max_size && value.size > max_size
      return [:error, error_i18n("file_max_size", max_size:)]
    end

    if content_types.any? && !content_types.include?(value.content_type)
      return [:error, error_i18n("file_content_type", allowed_content_types: content_types.inspect)]
    end

    [:ok, value]
  end

  concerning :Webpage do
    def summary
      "file"
    end

    def partial
      "explicit/documentation/type/file"
    end

    def has_details?
      max_size.present? || content_types.any?
    end
  end
end