# frozen_string_literal: true

class API::V1::SessionsController
  CreateRequest = API::V1::Request.new do
    post "/sessions"

    title "Log in"

    description <<~MD
    Attempts to sign in a user to the system. If sign in succeeds an
    authentication token is returned. Use this token to authenticate requests
    with the header `Authorization: Bearer <token>`.
    MD

    param :email_address, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true, downcase: true]
    param :password, [:string, min_length: 8]

    response 200, { token: :string }
    response 422, { error: "invalid_credentials" }
  end
end