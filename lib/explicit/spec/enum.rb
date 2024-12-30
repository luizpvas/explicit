# frozen_string_literal: true

class Explicit::Spec::Enum < Explicit::Spec
  attr_reader :allowed_values

  def initialize(allowed_values)
    @allowed_values = allowed_values
  end

  def validate(value)
    if allowed_values.include?(value)
      [:ok, value]
    else
      [:error, [:enum, allowed_values]]
    end
  end
end