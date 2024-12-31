# frozen_string_literal: true

module Explicit::Documentation
  class Builder
    attr_reader :sections

    def initialize
      @sections = []
      @current_section = nil
    end

    def page_title(page_title)
      @page_title = page_title
    end

    def section(name, &block)
      @current_section = Section.new(name:, pages: [])

      block.call

      @sections << @current_section

      @current_section = nil
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

    def call(request)
      @html ||= render_documentation_page

      [200, {}, [@html]]
    end

    private
      def render_documentation_page
        merge_request_examples_from_file!

        Explicit::ApplicationController.render(
          partial: "documentation",
          locals: {
            page_title: @page_title,
            sections: @sections
          }
        )
      end

      def merge_request_examples_from_file!
        return if !Explicit.configuration.request_examples_file_path

        encoded = ::File.read(Explicit.configuration.request_examples_file_path)
        examples = ::JSON.parse(encoded)

        @sections.each do |section|
          section.pages.filter(&:request?).each do |page|
            if examples.key?(page.request.gid)
              examples[page.request.gid].each do |example|
                page.request.add_example(
                  params: example["params"].with_indifferent_access,
                  headers: example["headers"],
                  response: {
                    status: example.dig("response", "status"),
                    data: example.dig("response", "data").with_indifferent_access
                  }
                )
              end
            end
          end
        end
      end
  end
end
