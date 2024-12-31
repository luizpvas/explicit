# frozen_string_literal: true

class API::V1::ArticlesController
  CreateRequest = API::V1::Authentication::AuthenticatedRequest.new do
    post "/articles"

    param :title, [:string, empty: false]
    param :content, [:string, empty: false]
    param :published_at, [:nilable, :date_time_iso8601]

    response 201, { article: Resource::Spec }
  end
end