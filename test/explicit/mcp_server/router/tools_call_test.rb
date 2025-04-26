# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::ToolsCallTest < ::ActiveSupport::TestCase
  test "tool call without path params" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)

    request = ::Explicit::MCPServer::Request.new(
      id: 1, 
      method: "tools/call", 
      params: {
        "name" => "get_articles",
        "arguments" => {
          "published_between" => "2025-04-01..2025-04-03"
        }
      },
      host: "localhost",
      headers: {
        "Authorization" => "Bearer #{token.value}"
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

    expected_response = {
      content: [
        {
          type: "text",
          text: {
            articles: [
              {
                id: article.id,
                title: article.title,
                content: article.content,
                published_at: article.published_at,
                read_count: article.read_count
              }
            ]
          }.to_json
        }
      ],
      isError: false
    }

    assert_equal expected_response, response.value
  end

  test "tool call with path params" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)
    
    request = ::Explicit::MCPServer::Request.new(
      id: 1,
      method: "tools/call",
      params: {
        "name" => "put_articles_by_article_id",
        "arguments" => {
          "article_id" => article.id,
          "title" => "New Title",
          "content" => "New Content"
        }
      },
      host: "localhost",
      headers: {
        "Authorization" => "Bearer #{token.value}"
      }
    )

    router = ::Explicit::MCPServer::Router.new(
      name: "test-server",
      version: "1.0",
      tools: [
        ::Explicit::MCPServer::Tool.new(::API::V1::ArticlesController::UpdateRequest)
      ]
    )

    response = router.handle(request)

    assert response.result?
    assert_equal 1, response.id

    expected_response = {
      content: [
        {
          type: "text",
          text: {
            article: {
              title: "New Title",
              content: "New Content",
              published_at: nil,
              id: article.id,
              read_count: 0
            }
          }.to_json
        }
      ],
      isError: false
    }

    assert_equal expected_response, response.value
  end

  test "returns error when tool is not found" do
    request = ::Explicit::MCPServer::Request.new(
      id: 1, 
      method: "tools/call", 
      params: {
        "name" => "non_existing_tool",
        "arguments" => {}
      },
      host: "localhost",
      headers: {}
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