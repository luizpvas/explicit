# frozen_string_literal: true

class Explicit::Type::Array < Explicit::Type
  attr_reader :item_type, :empty

  def initialize(item_type:, empty: true)
    @item_type = Explicit::Type.build(item_type)
    @empty = empty
  end

  def validate(values)
    return [:error, :array] if !values.is_a?(::Array)

    if values.empty? && !empty
      return [:error, :empty]
    end

    validated = []

    values.each.with_index do |value, index|
      case item_type.validate(value)
      in [:ok, value]
        validated << value
      in [:error, error]
        return [:error, error_i18n("array", index:, error:)]
      end
    end

    [:ok, validated]
  end

  concerning :Webpage do
    def summary
      "array of #{item_type.summary}"
    end

    def partial
      "explicit/documentation/type/array"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      {
        type: "array",
        items: item_type.swagger_schema,
        minItems: empty ? 0 : 1,
        description: swagger_description([])
      }.compact_blank
    end
  end
end
