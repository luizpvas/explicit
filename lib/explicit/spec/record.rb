# frozen_string_literal: true

class Explicit::Spec::Record < Explicit::Spec
  attr_reader :attributes

  def initialize(attributes:)
    @attributes = attributes

    @validators = attributes.map do |attribute_name, attribute_spec|
      [attribute_name, Explicit::Spec.build(attribute_spec)]
    end
  end

  def call(data)
    return [:error, :hash] if !data.respond_to?(:[])

    validated_data = {}
    errors = {}

    @validators.each do |attribute_name, validator|
      value = data[attribute_name]

      case validator.call(value)
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
