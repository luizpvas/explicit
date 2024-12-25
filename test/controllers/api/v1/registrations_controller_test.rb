# frozen_string_literal: true

require "test_helper"

class API::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  Request = API::V1::RegistrationsController::CreateRequest

  setup { freeze_time }

  test "successful user registration" do
    response = fetch(Request, params: {
      name: "Yukihiro Matsumoto",
      email_address: "matz@ruby.org",
      password: "mystrongpassword",
      terms_of_use: true
    })

    assert_equal 200, response.status

    Token.find_by!(value: response.data[:token]).tap do |token|
      assert_equal "authentication", token.purpose
      assert_equal 30.days.from_now, token.expires_at
      assert_nil token.revoked_at
    end
  end

  test "registration attempt when email address is taken" do
    response = fetch(Request, params: {
      name: "Luiz",
      email_address: "luiz@example.org",
      password: "mystrongpassword",
      terms_of_use: true
    })

    assert_equal 422, response.status
    assert_equal "email_already_taken", response.data[:error]
  end

  test "invalid params" do
    response = fetch(Request, params: {})

    assert_equal 422,  response.status

    assert_equal response.data, {
      error: "invalid_params",
      params: {
        name: "must be a string",
        email_address: "must be a string",
        password: "must be a string",
        terms_of_use: "must be accepted"
      }
    }
  end
end
