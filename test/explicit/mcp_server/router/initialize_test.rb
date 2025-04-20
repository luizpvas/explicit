# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::InitializeTest < ActiveSupport::TestCase
  test "initialize request returns the correct response structure" do
    request = Explicit::MCPServer::Request.new(
      id: 1,
      method: "initialize",
      params: {},
      headers: {}
    )

    router = Explicit::MCPServer::Router.new(
      name: "My app",
      version: "1.0.0",
      tools: []
    )

    response = router.handle(request)

    assert response.result?
    assert_equal 1, response.id

    expected_value = {
      protocolVersion: "2024-11-05",
      capabilities: {
        tools: {
          listChanged: false
        }
      },
      serverInfo: {
        name: "My app",
        version: "1.0.0"
      }
    }

    assert_equal expected_value, response.value
  end
end 