# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::PingTest < ActiveSupport::TestCase
  test "responds with pong" do
    request = ::Explicit::MCPServer::Request.new(id: 1, method: "ping", params: {}, headers: {})
    router = ::Explicit::MCPServer::Router.new(name: "My app", version: "1.0.0", tools: [])
    response = router.handle(request)
    
    assert response.result?
    assert_equal({}, response.value)
  end
end
