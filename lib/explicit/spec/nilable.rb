# frozen_string_literal: true

module Explicit::Spec::Nilable
  extend self

  def build(subspec)
    subspec_validator = Explicit::Spec.build(subspec)

    lambda do |value|
      return [:ok, nil] if value.nil?

      subspec_validator.call(value)
    end
  end
end
