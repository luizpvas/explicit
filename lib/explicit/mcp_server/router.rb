# frozen_string_literal: true

class Explicit::MCPServer::Router
  def initialize(name:, version:, tools:)
    @name = name
    @version = version
    @tools = tools.index_by { _1.request.get_mcp_tool_name }
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

    route = tool.request.routes.first

    path = [
      tool.request.get_base_path,
      route.replace_path_params(arguments)
    ].compact_blank.join

    body_content, querystring =
      if route.accepts_request_body?
        [arguments.to_json, ""]
      else
        ["", arguments.to_query]
      end

    rack_input = ::StringIO.new(body_content)
    rack_input.rewind

    env = request.rack_env.merge({
      "REQUEST_METHOD" => route.method.to_s.upcase,
      "PATH_INFO" => path,
      "rack.input" => rack_input,
      "CONTENT_TYPE" => "application/json",
      "CONTENT_LENGTH" => body_content.bytesize.to_s,
      "QUERY_STRING" => querystring
    })

    request.headers.each do |key, value|
      env["HTTP_#{key.upcase.tr('-', '_')}"] = value
    end

    status, headers, body = Rails.application.call(env)
    response = ::ActionDispatch::Response.new(status, headers, body)

    request.result({
      content: [
        {
          type: "text",
          text: response.body
        }
      ],
      isError: response.status < 200 || response.status > 299
    })
  end
end
