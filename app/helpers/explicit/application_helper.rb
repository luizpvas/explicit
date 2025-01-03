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

    def format_request_example(request:, example:)
      line_break = '<span class="text-white">\</span>'

      <<~BASH.html_safe
      #{example.to_curl_lines.join(" #{line_break}\n")}

      # #{example.response.status} #{Rack::Utils::HTTP_STATUS_CODES[example.response.status]}
      #{JSON.pretty_generate(example.response.data)}
      BASH
    end
  end
end
