# frozen_string_literal: true

class Explicit::Type::OneOf < Explicit::Type
  attr_reader :subtypes

  def initialize(subtypes:)
    @subtypes = subtypes.map { Explicit::Type.build(_1) }
  end

  def validate(value)
    errors = []

    @subtypes.each do |subtype|
      case subtype.validate(value)
      in [:ok, validated_value]
        return [:ok, validated_value]
      in [:error, err]
        errors << err
      end
    end

    [:error, errors.join(" OR ")]
  end

  def jsontype
    @subtypes.all? { _1.is_a?(Explicit::Type::Record) } ? "object" : "any"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/one_of"
    end

    def has_details?
      true
    end
  end
end