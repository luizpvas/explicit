# frozen_string_literal: true

module Explicit::MCPServer
  extend self

  def new(&block)
    engine = ::Class.new(::Rails::Engine)

    builder = Builder.new.tap do |builder|
      builder.instance_eval(&block)
    end

    engine.routes.draw do
      match "/", to: builder, as: :explicit_mcp, via: :all
    end

    engine
  end
end
