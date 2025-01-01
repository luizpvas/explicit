# frozen_string_literal: true

class Explicit::Type::String < Explicit::Type
  attr_reader :empty, :strip, :format, :minlength, :maxlength

  def initialize(empty: nil, strip: nil, format: nil, minlength: nil, maxlength: nil)
    @empty = empty
    @strip = strip
    @format = format
    @minlength = minlength
    @maxlength = maxlength
  end

  def validate(value)
    return [:error, error_i18n("string")] if !value.is_a?(::String)

    value = value.strip if strip

    if empty == false && value.empty?
      return [:error, error_i18n("empty")]
    end

    if minlength && value.length < minlength
      return [:error, error_i18n("minlength", minlength:)]
    end

    if maxlength && value.length > maxlength
      return [:error, error_i18n("maxlength", maxlength:)]
    end

    if format && !format.match?(value)
      return [:error, error_i18n("format", regex: format.inspect)]
    end

    [:ok, value]
  end

  def jsontype
    "string"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/string"
    end

    def has_details?
      !empty.nil? || format.present? || minlength.present? || maxlength.present?
    end
  end
end