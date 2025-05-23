# frozen_string_literal: true

class Explicit::Type::Hash < Explicit::Type
  attr_reader :key_type, :value_type, :empty

  def initialize(key_type:, value_type:, empty: true)
    @key_type = Explicit::Type.build(key_type)
    @value_type = Explicit::Type.build(value_type)
    @empty = empty
  end

  def validate(value)
    if !value.respond_to?(:[]) || value.is_a?(::String) || value.is_a?(::Array)
      return error_i18n("hash")
    end

    return error_i18n("empty") if value.empty? && empty == false

    validated_hash = {}

    value.each do |key, value|
      case [key_type.validate(key), value_type.validate(value)]
      in [[:ok, validated_key], [:ok, validated_value]]
        validated_hash[validated_key] = validated_value
      in [[:error, error], _]
        return error_i18n("hash_key", key:, error:)
      in [_, [:error, error]]
        return error_i18n("hash_value", key:, error:)
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

  def json_schema(flavour)
    {
      type: "object",
      additionalProperties: value_type.mcp_schema,
      description_topics: [
        empty == false ? swagger_i18n("hash_not_empty") : nil
      ]
    }
  end
end
