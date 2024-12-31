# frozen_string_literal: true

class Explicit::Spec::Agreement < Explicit::Spec
  VALUES = ["true", "on", "1", 1].freeze
  OK = [:ok, true].freeze

  attr_reader :parse

  def initialize(parse: false)
    @parse = parse
  end

  def validate(value)
    if value == true
      OK
    elsif parse && VALUES.include?(value)
      OK
    else
      [:error, error_i18n("agreement")]
    end
  end

  def jsontype
    "boolean"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/spec/agreement"
    end

    def has_details?
      true
    end
  end
end
