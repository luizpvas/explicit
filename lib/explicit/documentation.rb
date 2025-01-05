# frozen_string_literal: true

require "commonmarker"

module Explicit::Documentation
  extend self

  def new(&block)
    engine = ::Class.new(::Rails::Engine)

    builder = Builder.new(engine).tap do |builder|
      builder.instance_eval &block
      builder.merge_request_examples_from_file!
    end

    engine.define_singleton_method(:documentation_builder) { builder }
    
    engine.routes.draw do
      get "/", to: builder.webpage, as: :explicit_documentation_webpage
      get "/swagger", to: builder.swagger, as: :explicit_documentation_swagger
    end

    engine
  end
end
