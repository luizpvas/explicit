# frozen_string_literal: true

class Explicit::Spec::Hash < Explicit::Spec
  attr_reader :keyspec, :valuespec, :empty

  def initialize(keyspec:, valuespec:, empty: nil)
    @keyspec = Explicit::Spec.build(keyspec)
    @valuespec = Explicit::Spec.build(valuespec)
    @empty = empty
  end

  def call(value)
    return [:error, :hash] if !value.is_a?(::Hash)
    return [:error, :empty] if value.empty? && empty == false

    validated_hash = {}

    value.each do |key, value|
      case [keyspec.call(key), valuespec.call(value)]
      in [[:ok, validated_key], [:ok, validated_value]]
        validated_hash[validated_key] = validated_value
      in [[:error, err], _]
        return [:error, [:hash_key, key, err]]
      in [_, [:error, err]]
        return [:error, [:hash_value, key, err]]
      end
    end

    [:ok, validated_hash]
  end
end
