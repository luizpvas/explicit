# frozen_string_literal: true

module Explicit::Spec::Bigdecimal
  extend self

  ERROR = [:error, :bigdecimal].freeze

  def build(options)
    lambda do |value|
      return ERROR unless value.is_a?(::String) || value.is_a?(::Integer)

      decimalvalue = BigDecimal(value)

      if (min = options[:min]) && decimalvalue < min
        return [:error, [:min, min]]
      end

      if (max = options[:max]) && decimalvalue > max
        return [:error, [:max, max]]
      end

      [:ok, decimalvalue]
    rescue ArgumentError
      ERROR
    end
  end
end
