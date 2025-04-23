# frozen_string_literal: true

module Explicit::Documentation::Output
  class Webpage
    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    def call(env)
      @html ||= render_documentation_page(host: env["HTTP_HOST"])

      [200, {}, [@html]]
    end

    def inspect
      "#{self.class.name}#call"
    end

    private
      Eval = ->(value) { value.respond_to?(:call) ? value.call : value }

      def render_documentation_page(host:)
        Explicit::ApplicationController.render(
          partial: "explicit/documentation/page",
          locals: {
            host:,
            url_helpers: @builder.rails_engine.routes.url_helpers,
            page_title: Eval[builder.get_page_title],
            company_logo_url: Eval[builder.get_company_logo_url],
            favicon_url: Eval[builder.get_favicon_url],
            version: Eval[builder.get_version],
            sections: builder.sections,
          }
        )
      end
  end
end
