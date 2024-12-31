# frozen_string_literal: true

require "commonmarker"

module Explicit::Documentation
  extend self

  def new(&block)
    builder = Builder.new.tap { _1.instance_eval &block }

    builder.merge_request_examples_from_file!

    ::Class.new(::Rails::Engine).tap do |engine|
      engine.routes.draw do
        root to: builder.webpage
        get "/swagger", to: builder.swagger
      end
    end
  end
end
