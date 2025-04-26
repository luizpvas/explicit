# frozen_string_literal: true

module Explicit::MCPServer::Response
  Result = Data.define(:id, :value) do
    def result? = true
    def error? = false

    def to_json
      {
        jsonrpc: "2.0",
        id:,
        result: value
      }.to_json
    end
  end

  Error = Data.define(:id, :value) do
    def result? = false
    def error? = true

    def to_json
      {
        jsonrpc: "2.0",
        id:,
        error: value
      }.to_json
    end
  end
end 