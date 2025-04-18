# frozen_string_literal: true

module Explicit::MCPServer::Router
  extend self

  def handle(request)
    case request.method
    when "ping" then ping(request)
    when "initialize" then initialize_request(request)
    when "notifications/initialized" then raise ::NotImplementedError
    when "tools/list" then raise ::NotImplementedError
    when "tools/call" then raise ::NotImplementedError
    else raise ::NotImplementedError
    end
  end

  private

  def ping(request)
    request.result("pong")
  end

  def initialize_request(request)
    request.result({
      protocolVersion: "2.0",
      capabilities: {
        tools: {
          listChanged: false
        }
      },
      serverInfo: {
        name: "",
        version: ""
      }
    })
  end
end
