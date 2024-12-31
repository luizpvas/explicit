# frozen_string_literal: true

class Explicit::Spec::Record < Explicit::Spec
  attr_reader :attributes

  def initialize(attributes:)
    @attributes = attributes.map do |attribute_name, spec|
      [attribute_name, Explicit::Spec.build(spec)]
    end
  end

  def validate(data)
    return [:error, error_i18n("hash")] if !data.respond_to?(:[])

    validated_data = {}
    errors = {}

    @attributes.each do |attribute_name, spec|
      value = data[attribute_name]

      case spec.validate(value)
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
    def partial
      "explicit/documentation/spec/record"
    end
  end
end
