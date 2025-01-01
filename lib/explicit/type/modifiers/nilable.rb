# frozen_string_literal: true

module Explicit::Type::Modifiers::Nilable
  extend self

  def apply(type)
    Explicit::Type.build(type).tap do |type|
      type.nilable = true if type.is_a?(Explicit::Type) # TODO: remove check

      original_validate = type.method(:validate)

      type.define_singleton_method(:validate, lambda do |value|
        return [:ok, nil] if value.nil?

        original_validate.(value)
      end)
    end
  end
end
