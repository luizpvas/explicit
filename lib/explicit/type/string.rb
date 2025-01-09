# frozen_string_literal: true

class Explicit::Type::String < Explicit::Type
  attr_reader :empty, :strip, :format, :min_length, :max_length, :downcase

  def initialize(empty: nil, strip: nil, format: nil, min_length: nil, max_length: nil, downcase: false)
    @empty = empty
    @strip = strip
    @format = format
    @min_length = min_length
    @max_length = max_length
    @downcase = downcase
  end

  def validate(value)
    return [:error, error_i18n("string")] if !value.is_a?(::String)

    value = value.strip if strip
    value = value.downcase if downcase

    if empty == false && value.empty?
      return [:error, error_i18n("empty")]
    end

    if min_length && value.length < min_length
      return [:error, error_i18n("min_length", min_length:)]
    end

    if max_length && value.length > max_length
      return [:error, error_i18n("max_length", max_length:)]
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
      !empty.nil? || format.present? || min_length.present? || max_length.present?
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: "string",
        pattern: format&.inspect,
        minLength: min_length || (empty == false ? 1 : nil),
        maxLength: max_length,
        description_topics: [
          empty == false ? swagger_i18n("string_not_empty") : nil,
          downcase == true ? swagger_i18n("string_downcase") : nil
        ]
      })
    end
  end
end