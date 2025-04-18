# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(name:, version:)
    @name = name
    @version = version
  end

  def handle(request)
    case request.method
    when "ping" then ping(request)
    when "initialize" then do_initialize(request)
    when "notifications/initialized" then noop(request)
    when "tools/list" then raise ::NotImplementedError
    when "tools/call" then raise ::NotImplementedError
    else raise ::NotImplementedError
    end
  end

  private

  def noop(request)
    request.result(nil)
  end

  def ping(request)
    request.result("pong")
  end

  def do_initialize(request)
    request.result({
      protocolVersion: "2.0",
      capabilities: {
        tools: {
          listChanged: false
        }
      },
      serverInfo: {
        name: @name,
        version: @version
      }
    })
  end
end
