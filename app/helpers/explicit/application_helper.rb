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
      route = request.routes.first
      method = route.method.to_s.upcase
      url = request.get_base_url + request.get_base_path + route.replace_path_params(example.params)
      body = example.params.except(*route.params)

      br = '<span class="text-white">\</span>'

      curl_headers = example.headers.map.with_index do |(name, value), index|
        is_last = index == example.headers.size - 1

        "-H \"#{name}: #{value}\"#{is_last ? '' : ' ' + br}"
      end.join("\n")

      <<~BASH.html_safe
      curl -X#{method} "#{url}" #{br}
      -H "Content-Type: application/json" #{curl_headers.present? ? "#{br}\n" + curl_headers : "#{br}"}
      #{body.empty? ? "" : "-d '#{JSON.pretty_generate(body)}'"}

      # #{example.response.status} #{Rack::Utils::HTTP_STATUS_CODES[example.response.status]}
      #{JSON.pretty_generate(example.response.data)}
      BASH
    end
  end
end
