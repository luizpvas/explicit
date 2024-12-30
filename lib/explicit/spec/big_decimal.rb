# frozen_string_literal: true

class Explicit::Spec::BigDecimal < Explicit::Spec
  ERROR = [:error, :bigdecimal].freeze

  attr_reader :min, :max

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def call(value)
    return ERROR unless value.is_a?(::String) || value.is_a?(::Integer)

    decimalvalue = BigDecimal(value)

    if min && decimalvalue < min
      return [:error, [:min, min]]
    end

    if max && decimalvalue > max
      return [:error, [:max, max]]
    end

    [:ok, decimalvalue]
  rescue ArgumentError
    ERROR
  end
end
