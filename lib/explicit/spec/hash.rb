# frozen_string_literal: true

module Explicit::Spec::Hash
  extend self

  def build(keyspec, valuespec, options)
    keyspec_validator = Explicit::Spec.build(keyspec)
    valuespec_validator = Explicit::Spec.build(valuespec)

    lambda do |value|
      return [:error, :hash] if !value.is_a?(::Hash)
      return [:error, :empty] if value.empty? && !options[:empty]

      validated_hash = {}

      value.each do |key, value|
        case [keyspec_validator.call(key), valuespec_validator.call(value)]
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
end
