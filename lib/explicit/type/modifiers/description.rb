# frozen_string_literal: true

module Explicit::Type::Modifiers::Description
  extend self

  def apply(description, type)
    Explicit::Type.build(type).tap do |type|
      type.description = description
    end
  end
end