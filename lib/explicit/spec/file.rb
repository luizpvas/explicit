# frozen_string_literal: true

class Explicit::Spec::File < Explicit::Spec
  attr_reader :maxsize, :mime

  def initialize(maxsize: nil, mime: nil)
    @maxsize = maxsize
    @mime = Array(mime)
  end

  def validate(value)
    return [:error, error_i18n("file")] if !value.respond_to?(:tempfile)

    if maxsize && value.size > maxsize
      return [:error, error_i18n("file_maxsize", maxsize:)]
    end

    if mime.any? && !mime.include?(value.content_type)
      return [:error, error_i18n("file_mime", allowed_mimes: mime.inspect)]
    end

    [:ok, value]
  end

  def jsontype
    "file"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/spec/file"
    end

    def has_details?
      maxsize.present? || mime.present?
    end
  end
end