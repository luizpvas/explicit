# frozen_string_literal: true

class Explicit::MCPServer::Builder
  def initialize
    @tools = []
  end

  def name(name) = (@name = name)
  def get_name = @name

  def version(version) = (@version = version)
  def get_version = @version

  def tool(request)
    @tools << ::Explicit::MCPServer::Tool.new(request)
  end

  def call(env)
    request = ::Explicit::MCPServer::Request.from_rack_env(env)

    if respond_to?(:authorize)
      params = ::Rack::Utils.parse_nested_query(env["QUERY_STRING"]).with_indifferent_access

      case authorize(params:)
      in { headers: }
        request = request.with(headers:)
      else
        nil
      end
    end

    puts request.inspect

    response = router.handle(request)

    puts response.inspect

    [200, { "Content-Type" => "application/json" }, [response.to_json]]
  end

  def router
    @router ||= ::Explicit::MCPServer::Router.new(
      name: @name,
      version: @version,
      tools: @tools
    )
  end

  def proxy_with(headers:)
    { headers: }
  end
end
