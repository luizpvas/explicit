# frozen_string_literal: true

require "test_helper"

class API::V1::ArticlesController::IndexTest < ActionDispatch::IntegrationTest
  test "responds with articles authored by authenticated user" do
    token = users(:luiz).tokens.first
    article = articles(:published_by_luiz)

    response = fetch(
      API::V1::ArticlesController::IndexRequest,
      params: {
        published_between: "2025-04-01..2025-04-03"
      },
      headers: {
        Authorization: "Bearer #{token.value}"
      },
      save_as_example: true
    )

    assert_equal 200, response.status
    assert_equal [ article.id ], response.dig(:articles).map { _1[:id] }
  end
end
