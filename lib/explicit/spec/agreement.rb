# frozen_string_literal: true

module Explicit::Spec::Agreement
  extend self

  VALUES = ["true", "on", "1", 1].freeze

  def build(options)
    lambda do |value|
      value =
        if value.is_a?(TrueClass)
          value
        elsif VALUES.include?(value)
          true
        else
          nil
        end

      return [:error, :agreement] if value.nil?

      [:ok, value]
    end
  end
end
