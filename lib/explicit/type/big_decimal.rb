# frozen_string_literal: true

class Explicit::Type::BigDecimal < Explicit::Type
  attr_reader :min, :max

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def validate(value)
    if !value.is_a?(::BigDecimal) && !value.is_a?(::String) && !value.is_a?(::Integer)
      return [:error, error_i18n("big_decimal")]
    end

    decimal_value = BigDecimal(value)

    if min && decimal_value < min
      return [:error, error_i18n("min", min:)]
    end

    if max && decimal_value > max
      return [:error, error_i18n("max", max:)]
    end

    [:ok, decimal_value]
  rescue ArgumentError
    return [:error, error_i18n("big_decimal")]
  end

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/big_decimal"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: "string",
        pattern: /^\d*\.?\d*$/.inspect,
        format: "decimal number",
        description_topics: [
          min&.then { swagger_i18n("big_decimal_min", min: _1) },
          max&.then { swagger_i18n("big_decimal_max", max: _1) }
        ]
      })
    end
  end
end
