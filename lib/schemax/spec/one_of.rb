# frozen_string_literal: true

module Schemax::Spec::OneOf
  extend self

  def build(subspecs)
    subspec_validators = subspecs.map { Schemax::Spec.build(_1) }

    errors = []

    lambda do |value|
      subspec_validators.each do |subspec_validator|
        case subspec_validator.call(value)
        in [:ok, validated_value] then return [:ok, validated_value]
        in [:error, err] then errors << err
        end
      end

      [:error, [:one_of, *errors]]
    end
  end
end