# frozen_string_literal: true

module Schemax::Spec::Literal
  extend self

  def build(literal_value)
    lambda do |value|
      if value == literal_value
        [:ok, value]
      else
        [:error, [:literal, literal_value]]
      end
    end
  end
end
