# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::Router::PingTest < ActiveSupport::TestCase
  test "responds with pong" do
    request = ::Explicit::MCPServer::Request.new(id: 1, method: "ping", params: {})
    response = ::Explicit::MCPServer::Router.handle(request)
    
    assert response.result?
    assert_equal "pong", response.value
  end
end
