# frozen_string_literal: true

require "test_helper"

class API::V1::SessionsController::CreateTest < ActionDispatch::IntegrationTest
  Request = API::V1::SessionsController::CreateRequest

  test "successful login" do
    response = fetch(Request, params: {
      email_address: "luiz@example.org",
      password: "mystrongpassword"
    })

    assert_equal 200, response.status
    assert response.data[:token]
  end

  test "email does not belong to any user" do
    response = fetch(Request, params: {
      email_address: "non-existing-user@example.org",
      password: "any-password"
    })

    assert_equal 422, response.status
    assert_equal "invalid_credentials", response.data[:error]
  end

  test "wrong password" do
    response = fetch(Request, params: {
      email_address: "luiz@example.org",
      password: "wrong-password"
    })

    assert_equal 422, response.status
    assert_equal "invalid_credentials", response.data[:error]
  end

  test "invalid params" do
    response = fetch(Request, params: {})
    
    assert_equal 422, response.status
    assert_equal response.data, {
      error: "invalid_params",
      params: {
        email_address: "must be a string",
        password: "must be a string"
      }
    }
  end
end
