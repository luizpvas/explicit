# frozen_string_literal: true

class Explicit::Type::Float < Explicit::Type
  attr_reader :min, :max, :negative, :positive

  def initialize(min: nil, max: nil, negative: nil, positive: nil)
    @min = min
    @max = max
    @negative = negative
    @positive = positive
  end

  ParseFromString = ->(value) do
    Float(value)
  rescue ::ArgumentError
    nil
  end

  def validate(value)
    value =
      if value.is_a?(::Integer) || value.is_a?(::Float) || value.is_a?(::BigDecimal)
        value
      elsif value.is_a?(::String)
        ParseFromString[value]
      else
        nil
      end

    return error_i18n("float") if value.nil?

    if min && value < min
      return error_i18n("min", min:)
    end

    if max && value > max
      return error_i18n("max", max:)
    end

    if negative == false && value < 0
      return error_i18n("not_negative")
    end

    if negative == true && value >= 0
      return error_i18n("only_negative")
    end

    if positive == false && value > 0
      return error_i18n("not_positive")
    end

    if positive == true && value <= 0
      return error_i18n("only_positive")
    end

    [ :ok, value ]
  end

  concerning :Webpage do
    def summary
      "float"
    end

    def partial
      "explicit/documentation/type/float"
    end

    def has_details?
      min.present? || max.present? || !negative.nil? || !positive.nil?
    end
  end

  def swagger_schema
    merge_base_swagger_schema({
      type: "number",
      minimum: min,
      maximum: max,
      description_topics: [
        positive == false ? swagger_i18n("number_not_positive") : nil,
        positive == true ? swagger_i18n("number_only_positive") : nil,
        negative == false ? swagger_i18n("number_not_negative") : nil,
        negative == true ? swagger_i18n("number_only_negative") : nil
      ]
    }.compact_blank)
  end

  def json_schema
    merge_base_json_schema({
      type: "number",
      minimum: min,
      maximum: max,
      description_topics: [
        positive == false ? swagger_i18n("number_not_positive") : nil,
        positive == true ? swagger_i18n("number_only_positive") : nil,
        negative == false ? swagger_i18n("number_not_negative") : nil,
        negative == true ? swagger_i18n("number_only_negative") : nil
      ]
    }.compact_blank)
  end
end
