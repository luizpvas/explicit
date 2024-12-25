# frozen_string_literal: true

require "test_helper"

class API::V1::SessionsController::DestroyTest < ActionDispatch::IntegrationTest
  Request = API::V1::SessionsController::DestroyRequest

  setup { freeze_time }

  test "successful logout" do
    token = tokens(:luiz_authentication)

    response = fetch(Request, headers: {
      Authorization: "Bearer #{token.value}"
    })

    assert_equal 200, response.status
    assert_equal "session revoked", response.dig(:message)
    assert_equal ::Time.current, token.reload.revoked_at
  end

  test "unauthenticated request" do
    response = fetch(Request, headers: {
      Authorization: "Bearer non-existing-token"
    })

    assert_equal 403, response.status
  end
end
