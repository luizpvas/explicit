# frozen_string_literal: true

class Explicit::MCPServer::Builder
  def initialize
    @requests = []
  end

  def name(name)
    @name = name
  end

  def version(version)
    @version = version
  end

  def add(request)
    @requests << request
  end

  def call(request)
    [200, {}, ["Hello, world!"]]
  end

  def router
    @router ||= ::Explicit::MCPServer::Router.new(
      name: @name,
      version: @version,
      tools: @requests.map { Tool.from_request(it) }
    )
  end
end
