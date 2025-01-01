# frozen_string_literal: true

class API::V1::ArticlesController
  ShowRequest = API::V1::Authentication::AuthenticatedRequest.new do
    get "/articles/:article_id"

    param :article_id, [:integer, negative: false, parse: true]

    response 200, { article: Resource::Type }
    response 404, {}
  end
end
