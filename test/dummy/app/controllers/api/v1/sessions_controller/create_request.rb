# frozen_string_literal: true

class API::V1::SessionsController
  CreateRequest = Explicit::Request.new do
    post "/api/v1/sessions"

    description <<~MD
    Attempts to sign in a user to the system. If sign in succeeds an
    authentication token is returned. Use this token to authenticate requests
    with the header `Authorization: Bearer <token>`.
    MD

    param :email_address, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :password, [:string, minlength: 8]

    response 200, { token: :string }
    response 422, { error: "invalid_credentials" }
  end
end