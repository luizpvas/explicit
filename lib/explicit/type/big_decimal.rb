# frozen_string_literal: true

class Explicit::Type::BigDecimal < Explicit::Type
  attr_reader :min, :max, :negative, :positive

  def initialize(min: nil, max: nil, negative: nil, positive: nil)
    @min = min
    @max = max
    @negative = negative
    @positive = positive
  end

  def validate(value)
    if !value.is_a?(::BigDecimal) && !value.is_a?(::String) && !value.is_a?(::Integer)
      return error_i18n("big_decimal")
    end

    decimal_value = BigDecimal(value)

    if min && decimal_value < min
      return error_i18n("min", min:)
    end

    if max && decimal_value > max
      return error_i18n("max", max:)
    end

    if negative == false && decimal_value < 0
      return error_i18n("not_negative")
    end

    if negative == true && decimal_value >= 0
      return error_i18n("only_negative")
    end

    if positive == false && decimal_value > 0
      return error_i18n("not_positive")
    end

    if positive == true && decimal_value <= 0
      return error_i18n("only_positive")
    end

    [:ok, decimal_value]
  rescue ArgumentError
    return error_i18n("big_decimal")
  end

  concerning :Webpage do
    def summary
      "decimal string"
    end

    def partial
      "explicit/documentation/type/big_decimal"
    end

    def has_details?
      true
    end
  end

  def json_schema(flavour)
    {
      type: "string",
      pattern: /^\d*\.?\d*$/.inspect[1..-2],
      format: "decimal number",
      description_topics: [
        swagger_i18n("big_decimal_format"),
        min&.then { swagger_i18n("big_decimal_min", min: _1) },
        max&.then { swagger_i18n("big_decimal_max", max: _1) },
        positive == false ? swagger_i18n("number_not_positive") : nil,
        positive == true ? swagger_i18n("number_only_positive") : nil,
        negative == false ? swagger_i18n("number_not_negative") : nil,
        negative == true ? swagger_i18n("number_only_negative") : nil
      ].compact
    }
  end
end
