# frozen_string_literal: true

class Explicit::Spec::Agreement < Explicit::Spec
  VALUES = ["true", "on", "1", 1].freeze
  ERROR = [:error, :agreement].freeze
  OK = [:ok, true].freeze

  attr_reader :parse

  def initialize(parse: false)
    @parse = parse
  end

  def call(value)
    if value == true
      OK
    elsif parse && VALUES.include?(value)
      OK
    else
      ERROR
    end
  end
end
