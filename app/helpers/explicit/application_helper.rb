# frozen_string_literal: true

module Explicit
  module ApplicationHelper
    def type_render(type)
      render partial: type.partial, locals: { type: }
    end

    def type_attribute_render(name:, type:)
      render partial: "explicit/documentation/attribute", locals: { name:, type: }
    end

    def type_has_details?(type)
      type.description.present? || type.has_details?
    end
  end
end
