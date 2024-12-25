# frozen_string_literal: true

module Explicit::Spec::Integer
  extend self

  def build(options)
    lambda do |value|
      value =
        if value.is_a?(::Integer)
          value
        elsif value.is_a?(::String) && options[:parse]
          parse_from_string(value)
        else
          nil
        end

      return [:error, :integer] if value.nil?

      if (min = options[:min]) && !validate_min(value, min)
        return [:error, [:min, min]]
      end

      if (max = options[:max]) && !validate_max(value, max)
        return [:error, [:max, max]]
      end

      if options[:negative] == false && value < 0
        return [:error, :negative]
      end

      if options[:positive] == false && value > 0
        return [:error, :positive]
      end

      [:ok, value]
    end
  end

  private
    def parse_from_string(value)
      Integer(value)
    rescue ::ArgumentError
      nil
    end

    def validate_min(value, min)
      value >= min
    end

    def validate_max(value, max)
      value <= max
    end
end
