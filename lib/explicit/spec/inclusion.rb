# frozen_string_literal: true

class Explicit::Spec::Inclusion < Explicit::Spec
  attr_reader :allowed_values

  def initialize(allowed_values)
    @allowed_values = allowed_values
  end

  def call(value)
    if allowed_values.include?(value)
      [:ok, value]
    else
      [:error, [:inclusion, allowed_values]]
    end
  end
end
