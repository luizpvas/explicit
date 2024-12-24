# frozen_string_literal: true

module Schemax::Documentation
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
      html = Schemax::ApplicationController.render("foo")

      [200, {}, [html]]
    end
  end

  def self.build(&block)
    builder = Builder.new

    ::Class.new(::Rails::Engine).tap do |engine|
      engine.routes.draw { root to: builder }
    end
  end
end
