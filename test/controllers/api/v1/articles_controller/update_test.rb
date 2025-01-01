# frozen_string_literal: true

require "test_helper"

class API::V1::ArticlesController::UpdateTest < ActionDispatch::IntegrationTest
  setup { freeze_time }

  test "updates an article" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::UpdateRequest,
      params: {
        article_id: article.id,
        title: "Updated Title",
        content: "Updated Content",
        published_at: Time.current.iso8601
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 200, response.status
    assert_equal article.id, response.dig(:article, :id)
    assert_equal "Updated Title", response.dig(:article, :title)
    assert_equal "Updated Content", response.dig(:article, :content)
    assert_equal Time.current.iso8601(3), response.dig(:article, :published_at)
    assert_equal article.read_count, response.dig(:article, :read_count)
  end

  test "updates an article from published to unpublished" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::UpdateRequest,
      params: {
        article_id: article.id,
        title: article.title,
        content: article.content,
        published_at: nil
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 200, response.status
    assert_nil response.dig(:article, :published_at)
  end

  test "responds with not found when article belongs to another user" do
    token = users(:mario).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::UpdateRequest,
      params: {
        article_id: article.id,
        title: "Updated title",
        content: "Updated content"
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 404, response.status
    assert_equal response.data, {}
  end

  test "unauthenticated" do
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::UpdateRequest,
      params: {
        article_id: article.id,
        title: "Updated title",
        content: "Updated content"
      },
      headers: {
        Authorization: "Bearer non-existing-token"
      },
      save_as_example: true
    )

    assert_equal 403, response.status
  end
end
