# frozen_string_literal: true

class Explicit::Spec::Array < Explicit::Spec
  attr_reader :itemspec, :empty

  def initialize(itemspec:, empty: true)
    @itemspec = Explicit::Spec.build(itemspec)
    @empty = empty
  end

  def validate(values)
    return [:error, :array] if !values.is_a?(::Array)

    if values.empty? && !empty
      return [:error, :empty]
    end

    validated = []

    values.each.with_index do |value, index|
      case itemspec.validate(value)
      in [:ok, value]  then validated << value
      in [:error, err] then return [:error, [:array, index, err]]
      end
    end

    [:ok, validated]
  end
end
