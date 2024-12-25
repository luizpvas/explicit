# frozen_string_literal: true

module Explicit::Spec::Record
  extend self

  def build(attributes)
    attributes_validators = attributes.map do |attribute_name, attribute_spec|
      [attribute_name, Explicit::Spec.build(attribute_spec)]
    end

    lambda do |data|
      return [:error, :hash] if !data.respond_to?(:[])

      validated_data = {}
      errors = {}

      attributes_validators.each do |attribute_name, attribute_validator|
        value = data[attribute_name]

        case attribute_validator.call(value)
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
