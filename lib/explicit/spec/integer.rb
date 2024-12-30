# frozen_string_literal: true

class Explicit::Spec::Integer < Explicit::Spec
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

  def call(value)
    value =
      if value.is_a?(::Integer)
        value
      elsif value.is_a?(::String) && parse
        ParseFromString[value]
      else
        nil
      end

    return [:error, :integer] if value.nil?

    if min && value < min
      return [:error, [:min, min]]
    end

    if max && value > max
      return [:error, [:max, max]]
    end

    if negative == false && value < 0
      return [:error, :negative]
    end

    if positive == false && value > 0
      return [:error, :positive]
    end

    [:ok, value]
  end
end
