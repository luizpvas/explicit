# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(name:, version:, tools:)
    @name = name
    @version = version
    @tools = tools
  end

  def handle(request)
    case request.method
    when "ping" then ping(request)
    when "initialize" then do_initialize(request)
    when "notifications/initialized" then noop(request)
    when "tools/list" then list_tools(request)
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

  def list_tools(request)
    request.result({ tools: @tools.map(&:serialize) })
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
