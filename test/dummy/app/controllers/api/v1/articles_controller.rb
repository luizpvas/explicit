# frozen_string_literal: true

class API::V1::ArticlesController < API::V1::BaseController
  before_action :authenticate_request!

  ARTICLE_SPEC = {
    id: [:integer, negative: false],
    title: [:string, empty: false],
    content: [:string, empty: false],
    published_at: [:nilable, :date_time_iso8601],
    read_count: [:integer, negative: false]
  }.freeze

  Serialize = ->(article) do
    article.as_json(only: %i[id title content published_at read_count])
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: {}, status: 404
  end

  CreateRequest = API::V1::Authentication::AuthenticatedRequest.new do
    post "/api/v1/articles"

    param :title, [:string, empty: false]
    param :content, [:string, empty: false]
    param :published_at, [:nilable, :date_time_iso8601]

    response 201, { article: ARTICLE_SPEC }
  end

  def create
    CreateRequest.validate!(params) => { title:, content:, published_at: }

    article = current_user.articles.create!(title:, content:, published_at:, read_count: 0)

    render json: { article: Serialize[article] }, status: 201
  end
  
  ShowRequest = API::V1::Authentication::AuthenticatedRequest.new do
    get "/api/v1/articles/:article_id"

    param :article_id, [:integer, negative: false, parse: true]

    response 200, { article: ARTICLE_SPEC }
    response 404, {}
  end

  def show
    ShowRequest.validate!(params) => { article_id: }

    article = current_user.articles.find(article_id)

    render json: { article: Serialize[article] }
  end

  UpdateRequest = API::V1::Authentication::AuthenticatedRequest.new do
    put "/api/v1/articles/:article_id"

    param :article_id, [:integer, negative: false, parse: true]
    param :title, [:string, empty: false]
    param :content, [:string, empty: false]
    param :published_at, [:nilable, :date_time_iso8601]

    response 200, { article: ARTICLE_SPEC }
    response 404, {}
  end

  def update
    UpdateRequest.validate!(params) => { article_id:, title:, content:, published_at: }

    article = current_user.articles.find(article_id)
    article.update!(title:, content:, published_at:)

    render json: { article: Serialize[article] }, status: 200
  end
end
