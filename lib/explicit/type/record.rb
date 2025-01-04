# frozen_string_literal: true

class Explicit::Type::Record < Explicit::Type
  attr_reader :attributes

  def initialize(attributes:)
    @attributes = attributes.map do |attribute_name, type|
      [attribute_name, Explicit::Type.build(type)]
    end
  end

  def validate(data)
    return [:error, error_i18n("hash")] if !data.respond_to?(:[])

    validated_data = {}
    errors = {}

    @attributes.each do |attribute_name, type|
      value = data[attribute_name]

      case type.validate(value)
      in [:ok, validated_value]
        validated_data[attribute_name] = validated_value
      in [:error, err]
        errors[attribute_name] = err
      end
    end

    return [:error, errors] if errors.any?

    [:ok, validated_data]
  end

  concerning :Webpage do
    def summary
      "object"
    end

    def partial
      "explicit/documentation/type/record"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_parameters
      attributes.map do |name, type|
        {
          name:,
          in: type.param_location_path? ? "path" : "body",
          description: type.description,
          required: !type.nilable,
          schema: type.swagger_schema
        }
      end
    end

    def swagger_schema
      {
        type: "object",
        properties: attributes.to_h do |name, type|
          [name, type.swagger_schema]
        end
      }
    end
  end
end
