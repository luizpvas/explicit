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

    return [:error, error_i18n("boolean")] if value.nil?

    [:ok, value]
  end

  def jsontype
    "boolean"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/spec/boolean"
    end

    def has_details?
      parse.present?
    end
  end
end
