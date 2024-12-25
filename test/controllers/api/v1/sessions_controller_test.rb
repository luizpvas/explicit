# frozen_string_literal: true

require "test_helper"

class API::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "successful login" do
    response = fetch(
      API::V1::SessionsController::CreateRequest,
      params: {
        email_address: "luiz@example.org",
        password: "mystrongpassword"
      }
    )

    assert_equal 200, response.status
    assert response.data[:token]
  end
end
