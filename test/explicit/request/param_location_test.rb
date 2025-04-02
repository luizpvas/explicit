# frozen_string_literal: true

require "test_helper"

class Explicit::Request::PathParamsTest < ::ActiveSupport::TestCase
  test "defines param location for path params" do
    request = ::Explicit::Request.new do
      get "/users/:user_id/messages/:message_id/comments/:comment_id"

      param :comment_id, :integer
    end

    assert_equal [ :_param_location, :path, :integer ], request.params[:comment_id]
  end

  test "defines param location for query params" do
    request = ::Explicit::Request.new do
      get "/users/:user_id/messages/:message_id/comments"

      param :status, :string
    end

    assert_equal [ :_param_location, :query, :string ], request.params[:status]
  end

  test "defines param location for request body" do
    request = ::Explicit::Request.new do
      post "/users"

      param :name, :string
    end

    assert_equal [ :_param_location, :body, :string ], request.params[:name]
  end

  test "automatically defines params for missing path params" do
    request = ::Explicit::Request.new do
      get "/users/:user_id/messages/:message_id/comments/:comment_id"

      param :comment_id, :integer
    end

    user_id = request.params[:user_id]
    message_id = request.params[:message_id]
    comment_id = request.params[:comment_id]

    assert_equal [ :_param_location, :path, :string ], user_id
    assert_equal [ :_param_location, :path, :string ], message_id
    assert_equal [ :_param_location, :path, :integer ], comment_id
  end
end
