# frozen_string_literal: true

class API::V1::ArticlesController
  UpdateRequest = API::V1::Authentication::AuthenticatedRequest.new do
    put "/articles/:article_id"

    title "Update article"

    param :article_id, [:integer, positive: true]
    param :title, [:string, empty: false]
    param :content, [:string, empty: false]
    param :published_at, [:nilable, :date_time_iso8601]

    response 200, { article: Resource::Type }
    response 404, {}
  end
end