# frozen_string_literal: true

module Explicit::Type::Modifiers::Description
  extend self

  def apply(description, type)
    Explicit::Type.build(type).tap do |type|
      type.description = description if type.is_a?(Explicit::Type) # TODO: remove check
    end
  end
end