# frozen_string_literal: true

module Explicit
  module ApplicationHelper
    def type_render(type)
      render partial: type.partial, locals: { type: }
    end

    def type_attribute_render(name:, type:)
      render partial: "explicit/documentation/attribute", locals: { name:, type: }
    end

    def type_constraints(&block)
      content_tag(:div, class: "flex flex-wrap gap-2", &block)
    end

    def type_constraint(name, value)
      content_tag(:div, class: "bg-neutral-200 px-1 text-sm") do
        content_tag(:span, name) + " " + content_tag(:span, value)
      end
    end

    def type_has_details?(type)
      type.description.present? || type.has_details?
    end
  end
end
