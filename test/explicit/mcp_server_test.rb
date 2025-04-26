# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServerTest < ::ActiveSupport::TestCase
  test "builds a rails engine when all requests are compatible with tool schema" do
    engine = ::Explicit::MCPServer.new do
      name "My app"
      version "1.0.0"
    end

    assert engine.ancestors.include?(::Rails::Engine)
  end

  test "raises an error when MCP server does not have a name" do
    assert_raises "MCP servers must have a name" do
      ::Explicit::MCPServer.new do
        version "1.0.0"
      end
    end
  end

  test "raises an error when MCP server does not have a version" do
    assert_raises "MCP servers must have a version" do
      ::Explicit::MCPServer.new do
        name "My app"
      end
    end
  end
end
