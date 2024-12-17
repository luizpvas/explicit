# frozen_string_literal: true

module Schema::Type::Schema
  extend self

  def build(attributes)
    attribute_specs = attributes.map do |attribute_name, spec|
      [attribute_name, Schema::Type::Composer.compose(spec)]
    end

    lambda do |data|
      validated_data = {}

      attribute_specs.each do |attribute_name, spec|
        value = data[attribute_name]

        case spec.call(value)
        in [:ok, validated_value]
          validated_data[attribute_name] = validated_value
        in [:error, err]
          return [:error, { attribute_name => err}]
        end
      end

      [:ok, validated_data]
    end
  end
end
