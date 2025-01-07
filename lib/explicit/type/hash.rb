# frozen_string_literal: true

class Explicit::Type::Hash < Explicit::Type
  attr_reader :key_type, :value_type, :empty

  def initialize(key_type:, value_type:, empty: true)
    @key_type = Explicit::Type.build(key_type)
    @value_type = Explicit::Type.build(value_type)
    @empty = empty
  end

  def validate(value)
    return [:error, error_i18n("hash")] if !value.respond_to?(:[])
    return [:error, error_i18n("empty")] if value.empty? && empty == false

    validated_hash = {}

    value.each do |key, value|
      case [key_type.validate(key), value_type.validate(value)]
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

  concerning :Webpage do
    def summary
      "object"
    end

    def partial
      "explicit/documentation/type/hash"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      {
        type: "object",
        additionalProperties: value_type.swagger_schema,
        description: swagger_description([
          empty == false ? swagger_i18n("hash_not_empty") : nil
        ])
      }
    end
  end
end
