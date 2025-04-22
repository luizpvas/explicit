# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(name:, version:, tools:)
    @name = name
    @version = version
    @tools = tools.index_by { it.request.get_mcp_tool_name }
  end

  def handle(request)
    case request.method
    when "ping" then noop(request)
    when "initialize" then initialize_(request)
    when "notifications/initialized" then noop(request)
    when "tools/list" then tools_list(request)
    when "tools/call" then tools_call(request)
    else noop(request)
    end
  end

  private

  def noop(request)
    request.result({})
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
    request.result({ tools: @tools.values.map(&:serialize) })
  end

  def tools_call(request)
    tool_name = request.params["name"]
    arguments = request.params["arguments"]

    tool = @tools[tool_name]

    if !tool
      return request.error({ code: -32602, message: "tool not found" })
    end

    session = ::ActionDispatch::Integration::Session.new(::Rails.application)
    session.host = request.host
    route = tool.request.routes.first
    path = [tool.request.get_base_path, route.path].compact_blank.join

    path, params =
      if route.accepts_request_body?
        [path, arguments]
      else
        ["#{path}?#{arguments.to_query}", nil]
      end

    session.process(route.method, path, params:, headers: request.headers)

    request.result({
      content: [
        {
          type: "text",
          text: session.response.body
        }
      ],
      isError: session.response.status < 200 || session.response.status > 299
    })
  end
end
