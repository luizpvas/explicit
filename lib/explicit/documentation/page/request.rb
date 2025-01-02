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
      return if @request.get_description.blank?

      Explicit::Documentation::Markdown.to_html(@request.get_description).html_safe
    end

    def anchor
      title.gsub(" ", "-").downcase
    end

    def partial
      "explicit/documentation/request"
    end
  end
end
