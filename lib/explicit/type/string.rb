# frozen_string_literal: true

class Explicit::Type::String < Explicit::Type
  attr_reader :empty, :strip, :format, :minlength, :maxlength, :downcase

  def initialize(empty: nil, strip: nil, format: nil, minlength: nil, maxlength: nil, downcase: false)
    @empty = empty
    @strip = strip
    @format = format
    @minlength = minlength
    @maxlength = maxlength
    @downcase = downcase
  end

  def validate(value)
    return [:error, error_i18n("string")] if !value.is_a?(::String)

    value = value.strip if strip
    value = value.downcase if downcase

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

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/string"
    end

    def has_details?
      !empty.nil? || format.present? || minlength.present? || maxlength.present?
    end
  end

  concerning :Swagger do
    def swagger_schema
      {
        type: "string",
        pattern: format&.inspect,
        minLength: minlength || (empty == false ? 1 : nil),
        maxLength: maxlength,
        description: swagger_description([
          empty == false ? swagger_i18n("string_not_empty") : nil,
          downcase == true ? swagger_i18n("string_downcase") : nil
        ])
      }.compact_blank
    end
  end
end