# frozen_string_literal: true

class Explicit::Spec::Boolean < Explicit::Spec
  VALUES = {
    "true" => true,
    "on" => true,
    "1" => true,
    1 => true,
    "false" => false,
    "off" => false,
    "0" => false,
    0 => false
  }.freeze

  ERROR = [:error, :boolean].freeze

  attr_reader :parse

  def initialize(parse: false)
    @parse = parse
  end

  def validate(value)
    value =
      if value == true || value == false
        value
      elsif parse && VALUES.key?(value)
        VALUES[value]
      else
        nil
      end

    return ERROR if value.nil?

    [:ok, value]
  end
end
