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
end