# frozen_string_literal: true

module API::V1
  MCPServer = ::Explicit::MCPServer.new
    add API::V1::ArticlesController::IndexRequest
    add API::V1::ArticlesController::CreateRequest
    add API::V1::ArticlesController::ShowRequest
    add API::V1::ArticlesController::UpdateRequest

    def authorize
      true
    end
  end
end