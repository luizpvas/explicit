# frozen_string_literal: true

module Explicit::Documentation
  Section = ::Data.define(:name, :pages)

  module Page
    class Partial
      attr_reader :title, :partial

      def initialize(title:, partial:)
        @title = title
        @partial = partial
      end

      def partial? = true
      def request? = false

      def anchor
        title.dasherize
      end
    end

    class Request
      attr_reader :request

      def initialize(request:)
        @request = request
      end

      def title
        @request.get_title
      end

      def anchor
        title.dasherize
      end

      def partial? = false
      def request? = true
    end
  end

  class Builder
    attr_reader :sections

    def initialize
      @sections = []
      @current_section = nil
    end

    def page_title(page_title)
      @page_title = page_title
    end

    def primary_color(primary_color)
      @primary_color = primary_color
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
      # read and merge request examples from file
      # contents = ::File.read(Explicit.configuration.request_examples_file_path)

      html = Explicit::ApplicationController.render(
        partial: "documentation",
        locals: {
          page_title: @page_title,
          primary_color: @primary_color,
          sections: @sections
        }
      )

      [200, {}, [html]]
    end
  end

  def self.build(&block)
    builder = Builder.new.tap { _1.instance_eval &block }

    ::Class.new(::Rails::Engine).tap do |engine|
      engine.routes.draw { root to: builder }
    end
  end
end
