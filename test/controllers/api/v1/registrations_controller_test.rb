# frozen_string_literal: true

require "test_helper"

class API::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup { freeze_time }

  test "successful user registration" do
    response = fetch(API::V1::RegistrationsController::CreateRequest,
      params: {
        name: "Luiz",
        email_address: "luiz@example.org",
        password: "mystrongpassword",
        terms_of_use: true
      }
    )

    assert_equal 200, response.status

    Token.find_by!(value: response.data[:token]).tap do |token|
      assert_equal "authentication", token.purpose
      assert_equal 30.days.from_now, token.expires_at
      assert_nil token.revoked_at
    end
  end

  test "invalid params" do
    response = fetch(API::V1::RegistrationsController::CreateRequest, params: {})

    assert_equal 422,  response.status

    assert_equal response.data, {
      name: "must be a string"
    }
  end
end
