# frozen_string_literal: true

module Explicit::Spec::Inclusion
  extend self

  def build(values)
    lambda do |value|
      if values.include?(value)
        [:ok, value]
      else
        [:error, [:inclusion, values]]
      end
    end
  end
end
