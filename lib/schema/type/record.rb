# frozen_string_literal: true

module Schema::Type::Record
  extend self

  def build(attributes)
    attribute_specs = attributes.map do |attribute_name, schema|
      [attribute_name, Schema::Type::Builder.build(schema)]
    end

    lambda do |data|
      validated_data = {}
      errors = {}

      attribute_specs.each do |attribute_name, spec|
        value = data[attribute_name]

        case spec.call(value)
        in [:ok, validated_value]
          validated_data[attribute_name] = validated_value
        in [:error, err]
          errors[attribute_name] = err
        end
      end

      return [:error, errors] if errors.any?

      [:ok, validated_data]
    end
  end
end
