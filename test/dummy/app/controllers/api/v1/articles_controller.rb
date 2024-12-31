# frozen_string_literal: true

class API::V1::ArticlesController < API::V1::BaseController
  before_action :authenticate_request!

  rescue_from ActiveRecord::RecordNotFound do
    render json: {}, status: 404
  end

  def create
    CreateRequest.validate!(params) => { title:, content:, published_at: }

    article = current_user.articles.create!(title:, content:, published_at:, read_count: 0)

    render json: { article: Resource::Serialize[article] }, status: 201
  end
  
  def show
    ShowRequest.validate!(params) => { article_id: }

    article = current_user.articles.find(article_id)

    render json: { article: Resource::Serialize[article] }
  end

  def update
    UpdateRequest.validate!(params) => { article_id:, title:, content:, published_at: }

    article = current_user.articles.find(article_id)
    article.update!(title:, content:, published_at:)

    render json: { article: Resource::Serialize[article] }, status: 200
  end
end
