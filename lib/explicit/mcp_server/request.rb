# frozen_string_literal: true

module Explicit::MCPServer
  Request = ::Data.define(:jsonrpc, :method, :params, :id)
end
