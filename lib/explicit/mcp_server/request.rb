# frozen_string_literal: true

module Explicit::MCPServer
  Request = ::Data.define(:id, :method, :params) do
    def result(value)
      ::Explicit::MCPServer::Response::Result.new(id:, value:)
    end

    def error(value)
      ::Explicit::MCPServer::Response::Error.new(id:, value:)
    end
  end
end
