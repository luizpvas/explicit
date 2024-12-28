# frozen_string_literal: true

module Explicit::Spec::Agreement
  extend self

  VALUES = [true, "true", "on", "1", 1].freeze
  ERROR = [:error, :agreement].freeze
  OK = [:ok, true].freeze

  def build(options)
    lambda do |value|
      return ERROR if !VALUES.include?(value)

      OK
    end
  end
end
