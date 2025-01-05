# frozen_string_literal: true

class Explicit::Type::BigDecimal < Explicit::Type
  attr_reader :min, :max

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def validate(value)
    unless value.is_a?(::String) || value.is_a?(::Integer)
      return [:error, error_i18n("bigdecimal")]
    end

    decimalvalue = BigDecimal(value)

    if min && decimalvalue < min
      return [:error, error_i18n("min", min:)]
    end

    if max && decimalvalue > max
      return [:error, error_i18n("max", max:)]
    end

    [:ok, decimalvalue]
  rescue ArgumentError
    return [:error, error_i18n("bigdecimal")]
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
      {
        type: "string",
        pattern: /^\d*\.?\d*$/.inspect,
        format: "decimal number"
      }
    end
  end
end
