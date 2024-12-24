# frozen_string_literal: true

module Schemax::Spec::Boolean
  extend self

  VALUES = {
    "true" => true,
    "on" => true,
    "1" => true,
    "false" => false,
    "off" => false,
    "0" => false
  }.freeze

  def build(options)
    lambda do |value|
      value =
        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          value
        elsif value.is_a?(::String)
          VALUES[value]
        else
          nil
        end

      return [:error, :boolean] if value.nil?

      [:ok, value]
    end
  end
end
