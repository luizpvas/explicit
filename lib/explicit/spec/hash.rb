# frozen_string_literal: true

class Explicit::Spec::Hash < Explicit::Spec
  attr_reader :keyspec, :valuespec, :empty

  def initialize(keyspec:, valuespec:, empty: nil)
    @keyspec = Explicit::Spec.build(keyspec)
    @valuespec = Explicit::Spec.build(valuespec)
    @empty = empty
  end

  def validate(value)
    return [:error, error_i18n("hash")] if !value.is_a?(::Hash)
    return [:error, error_i18n("empty")] if value.empty? && empty == false

    validated_hash = {}

    value.each do |key, value|
      case [keyspec.validate(key), valuespec.validate(value)]
      in [[:ok, validated_key], [:ok, validated_value]]
        validated_hash[validated_key] = validated_value
      in [[:error, error], _]
        return [:error, error_i18n("hash_key", key:, error:)]
      in [_, [:error, error]]
        return [:error, error_i18n("hash_value", key:, error:)]
      end
    end

    [:ok, validated_hash]
  end

  def jsontype
    "object"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/spec/hash"
    end

    def has_details?
      true
    end
  end
end
