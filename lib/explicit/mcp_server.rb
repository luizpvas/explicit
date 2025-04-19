# frozen_string_literal: true

module Explicit::MCPServer
  extend self

  def new(&block)
    engine = ::Class.new(::Rails::Engine)

    builder = Builder.new.tap do |builder|
      builder.instance_eval(&block)
    end

    if builder.get_name.blank?
      raise <<~TEXT
        MCP servers must have a name. For example:

        Explicit::MCPServer.new do
          name "My app"
        end
      TEXT
    end

    if builder.get_version.blank?
      raise <<~TEXT
        MCP servers must have a version. For example:

        Explicit::MCPServer.new do
          version "1.0.0"
        end
      TEXT
    end

    engine.routes.draw do
      match "/", to: builder, as: :explicit_mcp, via: :all
    end

    engine
  end
end
