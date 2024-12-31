# frozen_string_literal: true

class Explicit::Spec::OneOf < Explicit::Spec
  attr_reader :subspecs

  def initialize(subspecs:)
    @subspecs = subspecs.map { Explicit::Spec.build(_1) }
  end

  def validate(value)
    errors = []

    @subspecs.each do |subspec|
      case subspec.validate(value)
      in [:ok, validated_value]
        return [:ok, validated_value]
      in [:error, err]
        errors << err
      end
    end

    [:error, errors.join(" OR ")]
  end
end