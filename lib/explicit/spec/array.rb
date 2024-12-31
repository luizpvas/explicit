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
      in [:ok, value]
        validated << value
      in [:error, error]
        return [:error, error_i18n("array", index:, error:)]
      end
    end

    [:ok, validated]
  end

  def jsontype
    "array"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/spec/array"
    end

    def has_details?
      true
    end
  end
end
