# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(transport, request)
    @transport = transport
    @request = request
  end

  def handle
    case @request.method
    when "ping" then raise ::NotImplementedError
    when "initialize" then raise ::NotImplementedError
    when "notifications/initialized" then raise ::NotImplementedError
    when "tools/list" then raise ::NotImplementedError
    when "tools/call" then raise ::NotImplementedError
    else raise ::NotImplementedError
    end
  end
end
