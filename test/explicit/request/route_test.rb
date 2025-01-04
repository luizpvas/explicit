# frozen_string_literal: true

require "test_helper"

class Explicit::Request::RouteTest < ActiveSupport::TestCase
  Route = Explicit::Request::Route

  test "params" do
    assert_equal [], Route.new("post", "/").params
    assert_equal [:id], Route.new("post", "/:id").params
    assert_equal [:id], Route.new("post", "/articles/:id").params
    assert_equal [:id], Route.new("post", "/users/articles/:id").params
    assert_equal [:user_id, :id], Route.new("post", "/users/:user_id/articles/:id").params
  end

  test "path_with_params" do
    assert_equal(
      "/articles/10",
      Route.new("post", "/articles/:id").replace_path_params({ id: 10 })
    )

    assert_equal(
      "/users/15/articles/10",
      Route.new("post", "/users/:user_id/articles/:id").replace_path_params({ user_id: 15, id: 10 })
    )
  end

  test "path_with_curly_syntax" do
    assert_equal(
      "/articles/{id}",
      Route.new("post", "/articles/:id").path_with_curly_syntax
    )

    assert_equal(
      "/users/{user_id}/articles/{id}",
      Route.new("post", "/users/:user_id/articles/:id").path_with_curly_syntax
    )
  end
end
