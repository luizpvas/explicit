# frozen_string_literal: true

module Explicit::MCPServer::Response
  Result = Data.define(:id, :value) do
    def result? = true
    def error? = false
  end

  Error = Data.define(:id, :value) do
    def result? = false
    def error? = true
  end
end 