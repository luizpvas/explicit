# frozen_string_literal: true

module API::V1
  MCPServer = ::Explicit::MCPServer.new do
    name "Dummy App"
    version "1.0.0"

    tool API::V1::ArticlesController::IndexRequest
    tool API::V1::ArticlesController::CreateRequest
    tool API::V1::ArticlesController::ShowRequest
    tool API::V1::ArticlesController::UpdateRequest

    def authorize(params:)
      proxy_with headers: { "Authorization" => "Bearer #{params[:token]}" }
    end
  end
end