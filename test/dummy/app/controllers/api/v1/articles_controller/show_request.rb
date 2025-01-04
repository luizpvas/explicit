# frozen_string_literal: true

class API::V1::ArticlesController
  ShowRequest = API::V1::Authentication::AuthenticatedRequest.new do
    get "/articles/:article_id"

    title "Get article"

    param :article_id, [:integer, positive: true]

    response 200, { article: Resource::Type }
    response 404, {}
  end
end
