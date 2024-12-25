# frozen_string_literal: true

class API::V1::SessionsController < ApplicationController
  class CreateRequest < Explicit::Request
    post "/api/v1/sessions"

    description <<-MD
    Attempts to sign in a user to the system. If sign in succeeds an
    authentication token is returned. Use this token to authenticate requests
    with the header `Authorization: Bearer <token>`.
    MD

    param :email_address, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :password, [:string, minlength: 8]

    response 200, { token: :string }
    response 422, { error: "invalid_credentials" }
  end

  def create
    CreateRequest.validate!(params) => { email_address:, password: }

    if (user = User.authenticate_by(email_address:, password:))
      token = user.tokens.authentication.create!(
        expires_at: 30.days.from_now,
        ip_address: request.ip,
        user_agent: request.user_agent
      )

      render json: { token: token.value }
    else
      render json: { error: "invalid_credentials" }, status: 422
    end
  end
end
