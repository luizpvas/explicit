# frozen_string_literal: true

module Explicit::Type::Modifiers::AuthType
  extend self

  def apply(auth_type, type)
    Explicit::Type.build(type).tap do |type|
      type.auth_type = auth_type
    end
  end
end
