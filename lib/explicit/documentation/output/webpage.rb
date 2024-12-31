# frozen_string_literal: true

module Explicit::Documentation::Output
  class Webpage
    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    def call(request)
      @html ||= render_documentation_page

      [200, {}, [@html]]
    end

    private
      def render_documentation_page
        Explicit::ApplicationController.render(
          partial: "explicit/documentation/page",
          locals: {
            page_title: builder.get_page_title,
            sections: builder.sections
          }
        )
      end
  end
end
