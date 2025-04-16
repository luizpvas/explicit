# frozen_string_literal: true

class Explicit::MCPServer::Builder
  def initialize
    @requests = []
  end

  def add(request)
    @requests << request
  end

  def call(request)
    [200, {}, ["Hello, world!"]]
  end
end
