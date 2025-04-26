# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::RequestTest < ActiveSupport::TestCase
  test "from_rack_env parses the request body and query string correctly" do
    request_body = {
      "id" => "123",
      "method" => "test_method",
      "params" => { "body_key" => "body_value" }
    }.to_json

    env = {
      "rack.input" => ::StringIO.new(request_body),
      "HTTP_CONTENT_TYPE" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer token123",
      "HTTP_USER_AGENT" => "TestAgent/1.0",
      "HTTP_X_CUSTOM_HEADER" => "CustomValue",
      "HTTP_HOST" => "example.com"
    }

    request = ::Explicit::MCPServer::Request.from_rack_env(env)

    assert_equal "123", request.id
    assert_equal "test_method", request.method
    assert_equal({ "body_key" => "body_value" }, request.params)
    assert_equal "example.com", request.host
    
    assert_equal({
      "Content-Type" => "application/json",
      "Authorization" => "Bearer token123",
      "User-Agent" => "TestAgent/1.0",
      "X-Custom-Header" => "CustomValue"
    }, request.headers)
    
    refute_includes request.headers.keys, "Host"
  end
end 