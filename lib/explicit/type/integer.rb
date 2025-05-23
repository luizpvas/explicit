# frozen_string_literal: true

class Explicit::Type::Integer < Explicit::Type
  attr_reader :min, :max, :negative, :positive

  def initialize(min: nil, max: nil, negative: nil, positive: nil)
    @min = min
    @max = max
    @negative = negative
    @positive = positive
  end

  ParseFromString = ->(value) do
    Integer(value)
  rescue ::ArgumentError
    nil
  end

  def validate(value)
    value =
      if value.is_a?(::Integer)
        value
      elsif value.is_a?(::String)
        ParseFromString[value]
      else
        nil
      end

    return error_i18n("integer") if value.nil?

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
      "integer"
    end

    def partial
      "explicit/documentation/type/integer"
    end

    def has_details?
      min.present? || max.present? || !negative.nil? || !positive.nil?
    end
  end

  def json_schema(flavour)
    {
      type: "integer",
      minimum: min,
      maximum: max,
      description_topics: [
        positive == false ? swagger_i18n("number_not_positive") : nil,
        positive == true ? swagger_i18n("number_only_positive") : nil,
        negative == false ? swagger_i18n("number_not_negative") : nil,
        negative == true ? swagger_i18n("number_only_negative") : nil
      ].compact_blank
    }.compact_blank
  end
end
