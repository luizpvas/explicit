# frozen_string_literal: true

module Explicit::Documentation
  class Builder
    attr_reader :sections, :swagger, :webpage

    def initialize
      @sections = []
      @current_section = nil
      @swagger = Output::Swagger.new(self)
      @webpage = Output::Webpage.new(self)
    end

    def page_title(text) = (@page_title = text)
    def get_page_title = @page_title

    def company_logo_url(url) = (@company_logo_url = url)
    def get_company_logo_url = @company_logo_url

    def section(name, &block)
      @current_section = Section.new(name:, pages: [])

      block.call

      @sections << @current_section

      @current_section = nil
    end

    def requests
      @sections.flat_map(&:pages).filter(&:request?).map(&:request)
    end

    def add(*requests, **opts)
      raise ArgumentError(<<-MD) if @current_section.nil?
        You must define a section before adding a page. For example:

          section "Customers" do
            add CustomersController::CreateRequest
          end
      MD

      if requests.one?
        @current_section.pages << Page::Request.new(request: requests.first)
      elsif opts[:partial]
        @current_section.pages << Page::Partial.new(title: opts[:title], partial: opts[:partial])
      else
        raise ArgumentError("expected request or a partial")
      end
    end

    def merge_request_examples_from_file!
      return if !Explicit.configuration.request_examples_file_path

      encoded = ::File.read(Explicit.configuration.request_examples_file_path)

      examples = ::JSON.parse(encoded)

      requests.each do |request|
        examples[request.gid]&.each do |example|
          request.add_example(
            params: example["params"].with_indifferent_access,
            headers: example["headers"],
            response: {
              status: example.dig("response", "status"),
              data: example.dig("response", "data").with_indifferent_access
            }
          )
        end
      end
    rescue JSON::ParserError
      ::Rails.logger.error("[Explicit] Could not parse JSON in request examples file at #{Explicit.configuration.request_examples_file_path}")
    end
  end
end
