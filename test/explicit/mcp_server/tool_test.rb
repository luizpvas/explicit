# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::ToolTest < ::ActiveSupport::TestCase
  test "builds a tool from a request when params are compatible" do
    request = ::Explicit::Request.new do
      get "/users/:id"
      param :id, :string
    end

    tool = ::Explicit::MCPServer::Tool.new(request)

    expected_output = {
      name: "get_users_by_id",
      inputSchema: {
        type: "object",
        properties: {
          id: { type: "string" }
        },
        required: ["id"],
        additionalProperties: false
      },
      annotations: {
        title: "GET /users/:id"
      }
    }

    assert_equal expected_output, tool.serialize
  end
end
