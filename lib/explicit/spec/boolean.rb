# frozen_string_literal: true

module Explicit::Spec::Boolean
  extend self

  VALUES = {
    true => true,
    "true" => true,
    "on" => true,
    "1" => true,
    1 => true,
    false => false,
    "false" => false,
    "off" => false,
    "0" => false,
    0 => false
  }.freeze

  ERROR = [:error, :boolean].freeze

  def build(options)
    lambda do |value|
      value = VALUES[value]

      return ERROR if value.nil?

      [:ok, value]
    end
  end
end
