# frozen_string_literal: true

require "test_helper"

class API::V1::ArticlesController::ShowTest < ActionDispatch::IntegrationTest
  test "responds with article authored by authenticated user" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::ShowRequest,
      params: {
        article_id: article.id
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 200, response.status
    assert_equal article.id, response.dig(:article, :id)
    assert_equal article.title, response.dig(:article, :title)
    assert_equal article.content, response.dig(:article, :content)
    assert_equal article.published_at.iso8601(3), response.dig(:article, :published_at)
    assert_equal article.read_count, response.dig(:article, :read_count)
  end

  test "responds with not found when article belongs to another user" do
    token = users(:mario).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::ShowRequest,
      params: {
        article_id: article.id
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 404, response.status
  end

  test "unauthenticated" do
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::ShowRequest,
      params: {
        article_id: article.id
      },
      headers: {
        Authorization: "Bearer non-existing-token"
      },
      save_as_example: true
    )

    assert_equal 403, response.status
  end
end
