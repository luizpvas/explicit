# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::ToolTest < ::ActiveSupport::TestCase
  test "builds a tool from a request when params are compatible" do
    request = ::Explicit::Request.new do
      get "/users/:id"
      param :id, :string
    end

    tool = ::Explicit::MCPServer::Tool.from_request(request)

    assert_equal "get_users_by_id", tool.name
    assert_equal "GET /users/:id", tool.title
    assert_nil tool.description
  end
end
