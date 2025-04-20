# frozen_string_literal: true

require "test_helper"

class ExplicitMCPServerRequestTest < ActiveSupport::TestCase
  test "from_rack_env parses the request body and query string correctly" do
    request_body = {
      "id" => "123",
      "method" => "test_method",
      "params" => { "body_key" => "body_value" }
    }.to_json

    env = {
      "rack.input" => StringIO.new(request_body)
    }

    request = Explicit::MCPServer::Request.from_rack_env(env)

    assert_equal "123", request.id
    assert_equal "test_method", request.method
    assert_equal({ "body_key" => "body_value" }, request.params)
    assert_equal({}, request.headers)
  end
end 