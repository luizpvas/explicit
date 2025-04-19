# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::ToolsCallTest < ::ActiveSupport::TestCase
  test "calls a tool successfully" do
    request = ::Explicit::MCPServer::Request.new(
      id: 1, 
      method: "tools/call", 
      params: {
        "name" => "get_articles",
        "arguments" => {
          "published_between" => "2023-01-01..2023-12-31"
        }
      }
    )
    
    router = ::Explicit::MCPServer::Router.new(
      name: "test-server",
      version: "1.0",
      tools: [
        ::Explicit::MCPServer::Tool.new(::API::V1::ArticlesController::IndexRequest)
      ]
    )

    response = router.handle(request)

    assert response.result?
    assert_equal 1, response.id
    assert_equal({ articles: [{ id: 1, title: "Test Article" }] }, response.value)
  end

  test "returns error when tool is not found" do
    request = ::Explicit::MCPServer::Request.new(
      id: 1, 
      method: "tools/call", 
      params: {
        "name" => "non_existing_tool",
        "arguments" => {}
      }
    )
    
    router = ::Explicit::MCPServer::Router.new(
      name: "test-server",
      version: "1.0",
      tools: []
    )

    response = router.handle(request)

    assert response.error?
    assert_equal 1, response.id

    expected_error = {
      code: -32602,
      message: "tool not found"
    }

    assert_equal expected_error, response.value
  end
end 