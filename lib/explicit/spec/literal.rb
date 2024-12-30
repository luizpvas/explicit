# frozen_string_literal: true

class Explicit::Spec::Literal < Explicit::Spec
  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def validate(value)
    if value == @value
      [:ok, value]
    else
      [:error, [:literal, @value]]
    end
  end
end
