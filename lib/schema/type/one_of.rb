# frozen_string_literal: true

module Schema::Type::OneOf
  extend self

  def build(specs)
    specs = specs.map { Schema::Type::Builder.build(_1) }

    errors = []

    lambda do |value|
      specs.each do |spec|
        case spec.call(value)
        in [:ok, validated_value] then return [:ok, validated_value]
        in [:error, err] then errors << err
        end
      end

      [:error, [:one_of, *errors]]
    end
  end
end