# frozen_string_literal: true

module Explicit::Type::Modifiers::Default
  extend self

  def apply(default, type)
    Explicit::Type.build(type).tap do |type|
      type.default = default if type.is_a?(Explicit::Type) # TODO: remove check

      original_validate = type.method(:validate)

      type.define_singleton_method(:validate, lambda do |value|
        value =
          if value.nil?
            default.respond_to?(:call) ? default.call : default
          else
            value
          end

        original_validate.(value)
      end)
    end
  end
end