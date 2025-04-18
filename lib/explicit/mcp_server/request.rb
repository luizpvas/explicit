# frozen_string_literal: true

module Explicit::MCPServer
  Request = ::Data.define(:id, :method, :params) do
    def self.from_rack_env(env)
      body = ::JSON.parse(env["rack.input"].read)

      new(
        id: body["id"],
        method: body["method"],
        params: body["params"]
      )
    end

    def result(value)
      ::Explicit::MCPServer::Response::Result.new(id:, value:)
    end

    def error(value)
      ::Explicit::MCPServer::Response::Error.new(id:, value:)
    end
  end
end
