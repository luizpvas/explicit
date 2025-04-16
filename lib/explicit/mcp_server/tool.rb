# frozen_string_literal: true

module Explicit::MCPServer
  Tool = ::Data.define(
    :name,
    :title,
    :description,
    :arguments,
    :read_only_hint,
    :destructive_hint,
    :idempotent_hint,
    :open_world_hint
  ) do
    def self.from_request(request)
      new(
        name: request.get_mcp_tool_name,
        title: request.get_mcp_tool_title,
        description: request.get_mcp_tool_description,
        arguments: request.params_type.mcp_schema,
        read_only_hint: request.get_mcp_tool_read_only_hint,
        destructive_hint: request.get_mcp_tool_destructive_hint,
        idempotent_hint: request.get_mcp_tool_idempotent_hint,
        open_world_hint: request.get_mcp_tool_open_world_hint
      )
    end
  end
end
