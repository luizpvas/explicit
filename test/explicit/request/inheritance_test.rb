# frozen_string_literal: true

require "test_helper"

class Explicit::Request::InheritanceTest < ActiveSupport::TestCase
  AuthenticatedRequest = Explicit::Request.new do
    base_url "https://myapp.com"
    base_path "/api/v1"

    post "/users"

    header "Authorization", :string

    param :id, :integer

    response 403, { error: "unauthorized" }
  end

  Request = AuthenticatedRequest.new do
    put "/users/:id"

    header "Another", :string

    param :another, :integer

    response 200, {}
  end

  test "inheritance" do
    assert_equal "https://myapp.com", Request.get_base_url
    assert_equal "/api/v1", Request.get_base_path

    assert_equal 2, Request.routes.length
    assert_equal 2, Request.headers.length
    assert_equal 2, Request.params.length
    assert_equal 3, Request.responses.length
  end
end
