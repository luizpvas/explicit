# frozen_string_literal: true

require "test_helper"

class Explicit::Request::AuthorizationTest < ::ActiveSupport::TestCase
  test "detects basic authorization" do
    request = ::Explicit::Request.new do
      header "Authorization", [ :string, format: /Basic [\w]+/ ]
    end

    assert request.requires_basic_authorization?
    assert_not request.requires_bearer_authorization?
  end

  test "detects bearer authorization" do
    request = ::Explicit::Request.new do
      header "Authorization", [ :string, format: /Bearer [\w]+/ ]
    end

    assert request.requires_bearer_authorization?
    assert_not request.requires_basic_authorization?
  end
end
