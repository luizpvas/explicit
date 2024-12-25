# frozen_string_literal: true

module Explicit::Documentation
  class Builder
    def page_title(page_title)
      @page_title = page_title
    end

    def primary_color(primary_color)
      @primary_color = primary_color
    end

    def section(name)
    end

    def add(**opts)
    end

    def call(request)
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
