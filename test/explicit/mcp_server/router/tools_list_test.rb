# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::ListToolsTest < ::ActiveSupport::TestCase
  test "lists all available tools" do
    request = ::Explicit::MCPServer::Request.new(
      id: 1,
      method: "tools/list",
      params: {},
      query: {}
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

    expect_value = {
      tools: [
        {
          name: "get_articles",
          inputSchema: {
            type: "object",
            properties: {
              published_between: {
                type: "string",
                description: "* The value must be a range between two dates in the format of: \"YYYY-MM-DD..YYYY-MM-DD\"",
                pattern: "^(\\d{4}-\\d{2}-\\d{2})\\.\\.(\\d{4}-\\d{2}-\\d{2})$",
                format: "date range"
              }
            },
            required: ["published_between"],
            additionalProperties: false
          },
          annotations: {
            title: "List articles"
          }
        }
      ]
    }

    assert_equal expect_value, response.value
  end
end 