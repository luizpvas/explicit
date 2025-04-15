# frozen_string_literal: true

require "test_helper"

class Explicit::Request::MCPTest < ::ActiveSupport::TestCase
  test "mcp configuration" do
    request = ::Explicit::Request.new do
      mcp_tool_name "get_user_by_id"
      mcp_tool_title  "Get user by ID"
      mcp_tool_description "Attempts to find a user by ID and returns the email and name of the user."
      mcp_tool_read_only true
      mcp_tool_destructive false
      mcp_tool_idempotent true
      mcp_tool_open_world false
    end

    assert_equal "get_user_by_id", request.get_mcp_tool_name
    assert_equal "Get user by ID", request.get_mcp_tool_title
    assert_equal "Attempts to find a user by ID and returns the email and name of the user.", request.get_mcp_tool_description
    assert_equal true, request.get_mcp_tool_read_only
    assert_equal false, request.get_mcp_tool_destructive
    assert_equal true, request.get_mcp_tool_idempotent
    assert_equal false, request.get_mcp_tool_open_world
  end

  test "mcp_tool_name default value for route without params" do
    request = ::Explicit::Request.new do
      get "/admin/users"
    end

    assert_equal "get_admin_users", request.get_mcp_tool_name
  end

  test "mcp_tool_name default value for route with params" do
    request = ::Explicit::Request.new do
      get "/admin/users/:id"
    end

    assert_equal "get_admin_users_by_id", request.get_mcp_tool_name
  end
end
