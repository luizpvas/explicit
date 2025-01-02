# frozen_string_literal: true

class Explicit::Type::Integer < Explicit::Type
  attr_reader :min, :max, :parse, :negative, :positive

  def initialize(min: nil, max: nil, parse: nil, negative: nil, positive: nil)
    @min = min
    @max = max
    @parse = parse
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
      elsif value.is_a?(::String) && parse
        ParseFromString[value]
      else
        nil
      end

    return [:error, error_i18n("integer")] if value.nil?

    if min && value < min
      return [:error, error_i18n("min", min:)]
    end

    if max && value > max
      return [:error, error_i18n("max", max:)]
    end

    if negative == false && value < 0
      return [:error, error_i18n("not_negative")]
    end

    if positive == false && value > 0
      return [:error, error_i18n("not_positive")]
    end

    [:ok, value]
  end

  def jsontype
    "integer"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/integer"
    end

    def has_details?
      min.present? || max.present? || parse || !negative.nil? || !positive.nil?
    end
  end
end
