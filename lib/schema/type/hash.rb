# frozen_string_literal: true

module Schema::Type::Hash
  extend self

  def build(keyspec, valuespec, options)
    keyspec = Schema::Type::Builder.build(keyspec)
    valuespec = Schema::Type::Builder.build(valuespec)

    lambda do |value|
      return [:error, :hash] if !value.is_a?(::Hash)
      return [:error, :empty] if options[:empty] == false && value.empty?

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
end
