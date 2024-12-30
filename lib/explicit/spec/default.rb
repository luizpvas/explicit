# frozen_string_literal: true

module Explicit::Spec::Default
  extend self

  def apply(default, spec)
    Explicit::Spec.build(spec).tap do |spec|
      spec.default = default if spec.is_a?(Explicit::Spec) # TODO: remove check

      original_validate = spec.method(:validate)

      spec.define_singleton_method(:validate, lambda do |value|
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