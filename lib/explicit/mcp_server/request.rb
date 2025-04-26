# frozen_string_literal: true

require "rack/utils"

module Explicit::MCPServer
  Request = ::Data.define(:id, :method, :params, :host, :headers) do
    def self.from_rack_env(env)
      headers = env.each_with_object({}) do |(key, value), hash|
        if key.start_with?("HTTP_") && key != "HTTP_HOST"
          header_name = key[5..-1].split("_").map(&:capitalize).join("-")
          hash[header_name] = value
        end
      end

      body = ::JSON.parse(env["rack.input"].read)

      new(
        id: body["id"],
        method: body["method"],
        params: body["params"],
        host: env["HTTP_HOST"],
        headers:
      )
    rescue ::JSON::ParserError
      new(
        id: nil,
        method: nil,
        params: nil,
        host: env["HTTP_HOST"],
        headers: headers
      )
    end

    def result(value)
      ::Explicit::MCPServer::Response::Result.new(id:, value:)
    end

    def error(value)
      ::Explicit::MCPServer::Response::Error.new(id:, value:)
    end
  end
end
