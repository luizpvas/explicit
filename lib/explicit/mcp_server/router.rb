# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(name:, version:, tools:)
    @name = name
    @version = version
    @tools = tools
  end

  def handle(request)
    case request.method
    when "ping" then noop(request)
    when "initialize" then initialize_(request)
    when "notifications/initialized" then noop(request)
    when "tools/list" then tools_list(request)
    when "tools/call" then tools_call(request)
    else raise ::NotImplementedError
    end
  end

  private

  def noop(request)
    request.result(nil)
  end

  def initialize_(request)
    request.result({
      protocolVersion: "2024-11-05",
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

  def tools_list(request)
    request.result({ tools: @tools.map(&:serialize) })
  end

  def tools_call(request)
    tool_name = request.params["name"]
    arguments = request.params["arguments"]

    # TODO: lookup O(1)
    tool = @tools.find { |t| t.request.get_mcp_tool_name == tool_name }

    if !tool
      return request.error({ code: -32602, message: "tool not found" })
    end

    session = ::ActionDispatch::Integration::Session.new(::Rails.application)

    if tool.request.routes.first.method == :get
      session.get(tool.request.get_base_path + tool.request.routes.first.path + "?" + arguments.to_query)
    else
      session.post(tool.request.get_base_path + tool.request.routes.first.path, params: arguments)
    end

    request.result(session.response.body)
  end
end
