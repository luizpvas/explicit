# frozen_string_literal: true

module Explicit::MCPServer
  Tool = ::Data.define(
    :name,
    :title,
    :description,
    :input_schema,
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
        input_schema: request.params_type.mcp_schema,
        read_only_hint: request.get_mcp_tool_read_only_hint,
        destructive_hint: request.get_mcp_tool_destructive_hint,
        idempotent_hint: request.get_mcp_tool_idempotent_hint,
        open_world_hint: request.get_mcp_tool_open_world_hint
      )
    end

    def serialize
      {
        name:,
        description:,
        inputSchema: input_schema,
        annotations: {
          title:,
          readOnlyHint: read_only_hint,
          destructiveHint: destructive_hint,
          idempotentHint: idempotent_hint,
          openWorldHint: open_world_hint
        }.compact
      }.compact
    end
  end
end
