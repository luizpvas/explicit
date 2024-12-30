# frozen_string_literal: true

module Explicit::Spec::Nilable
  extend self

  def apply(spec)
    Explicit::Spec.build(spec).tap do |spec|
      spec.nilable = true if spec.is_a?(Explicit::Spec) # TODO: remove check

      original_call = spec.method(:call)

      spec.define_singleton_method(:call, lambda do |value|
        return [:ok, nil] if value.nil?

        original_call.(value)
      end)
    end
  end
end
