# frozen_string_literal: true

module Explicit::Spec::Modifiers::Description
  extend self

  def apply(description, spec)
    Explicit::Spec.build(spec).tap do |spec|
      spec.description = description if spec.is_a?(Explicit::Spec) # TODO: remove check
    end
  end
end