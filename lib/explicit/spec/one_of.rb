# frozen_string_literal: true

module Explicit::Spec::OneOf
  extend self

  def build(subspecs)
    subspec_validators = subspecs.map { Explicit::Spec.build(_1) }

    errors = []

    lambda do |value|
      subspec_validators.each do |subspec_validator|
        case subspec_validator.call(value)
        in [:ok, validated_value]
          return [:ok, validated_value]
        in [:error, err]
          errors << err
        end
      end

      # warning: weird heuristics below
      errors.each do |err|
        if looks_like_at_least_one_attribute_matched?(value, err)
          return [:error, err]
        end
      end

      [:error, [:one_of, *errors]]
    end
  end

  private
    def looks_like_at_least_one_attribute_matched?(value, err)
      return false if !value.is_a?(::Hash)
      return false if !err.is_a?(::Hash)

      keyset = value.keys - err.keys

      keyset.empty?
    end
end