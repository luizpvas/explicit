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

    puts request.inspect

    response = router.handle(request)

    puts response.inspect

    headers = {
      "Content-Type" => "application/json"
    }

    [200, headers, [response.to_json]]
  end

  def router
    @router ||= ::Explicit::MCPServer::Router.new(
      name: @name,
      version: @version,
      tools: @tools
    )
  end
end
