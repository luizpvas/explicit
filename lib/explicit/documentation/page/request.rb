# frozen_string_literal: true

module Explicit::Documentation::Page
  class Request
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def request?
      true
    end

    def title
      @request.get_title
    end

    def description_html
      Explicit::Documentation::Markdown.to_html(@request.get_description).html_safe
    end

    def anchor
      title.dasherize
    end

    def partial
      "request"
    end
  end
end
