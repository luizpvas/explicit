# frozen_string_literal: true

class API::V1::ArticlesController
  IndexRequest = API::V1::Authentication::AuthenticatedRequest.new do
    get "/articles"

    title "List articles"

    param :published_between, :date_range

    response 200, { articles: [ :array, Resource::Type ] }
  end
end
