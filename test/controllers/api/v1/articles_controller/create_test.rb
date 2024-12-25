# frozen_string_literal: true

require "test_helper"

class API::V1::ArticlesController::CreateTest < ActionDispatch::IntegrationTest
  setup { freeze_time }

  test "creates a published article (with published_at)" do
    response = fetch(
      API::V1::ArticlesController::CreateRequest,
      params: {
        title: "Article title",
        content: "Article content",
        published_at: ::Time.current.iso8601
      },
      headers: {
        Authorization: "Bearer #{tokens(:luiz_authentication).value}"
      },
      save_as_example: true
    )

    assert_equal 201, response.status

    assert response.dig(:article, :id)
    assert_equal "Article title", response.dig(:article, :title)
    assert_equal "Article content", response.dig(:article, :content)
    assert_equal ::Time.current.iso8601(3), response.dig(:article, :published_at)
    assert_equal 0, response.dig(:article, :read_count)
  end

  test "creates a draft article (without published_at)" do
    response = fetch(
      API::V1::ArticlesController::CreateRequest,
      params: {
        title: "Article title",
        content: "Article content"
      },
      headers: {
        Authorization: "Bearer #{tokens(:luiz_authentication).value}"
      },
      save_as_example: true
    )

    assert_equal 201, response.status
    
    assert response.dig(:article, :id)
    assert_equal "Article title", response.dig(:article, :title)
    assert_equal "Article content", response.dig(:article, :content)
    assert_nil response.dig(:article, :published_at)
    assert_equal 0, response.dig(:article, :read_count)
  end
end
