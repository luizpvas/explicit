# frozen_string_literal: true

module Explicit::Type::Modifiers::ParamLocation
  extend self

  def apply(param_location, type)
    Explicit::Type.build(type).tap do |type|
      type.param_location = param_location
    end
  end
end