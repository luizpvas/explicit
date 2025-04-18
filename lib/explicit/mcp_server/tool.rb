# frozen_string_literal: true

module Explicit::MCPServer
  Tool = ::Data.define(:request) do
    def serialize
      {
        name: request.get_mcp_tool_name,
        description: request.get_mcp_tool_description,
        inputSchema: request.params_type.mcp_schema,
        annotations: {
          title: request.get_mcp_tool_title,
          readOnlyHint: request.get_mcp_tool_read_only_hint,
          destructiveHint: request.get_mcp_tool_destructive_hint,
          idempotentHint: request.get_mcp_tool_idempotent_hint,
          openWorldHint: request.get_mcp_tool_open_world_hint
        }.compact
      }.compact
    end
  end
end
