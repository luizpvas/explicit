# frozen_string_literal: true

require "test_helper"

class Explicit::Request::AuthorizationTest < ::ActiveSupport::TestCase
  test "detects basic authorization based on format" do
    request = ::Explicit::Request.new do
      header "Authorization", [ :string, format: /Basic [\w]+/ ]
    end

    assert request.requires_basic_authorization?
  end

  test "detects tagged basic authorization" do
    request = ::Explicit::Request.new do
      header "Authorization", :string, auth: :basic
    end

    assert request.requires_basic_authorization?
  end

  test "detects bearer authorization based on format" do
    request = ::Explicit::Request.new do
      header "Authorization", [ :string, format: /Bearer [\w]+/ ]
    end

    assert request.requires_bearer_authorization?
  end

  test "detects tagged bearer authorization" do
    request = ::Explicit::Request.new do
      header "Authorization", :string, auth: :bearer
    end

    assert request.requires_bearer_authorization?
  end
end
