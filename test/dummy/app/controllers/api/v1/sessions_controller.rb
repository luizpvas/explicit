# frozen_string_literal: true

class API::V1::SessionsController < ApplicationController
  class Request < Schemax::Request
    post "/api/v1/sessions"

    description "Attempts to sign in a user to the system."

    param :email_address, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :password, [:string, empty: false]

    response 200, { authentication_token: :string }
    response 422, { error: "invalid_credentials" }
  end

  def create
    Request.validate!(params) => { email_address:, password: }

    if (user = User.authenticate_by(email_address:, password:))
      authentication_token = ::SecureRandom.alphanumeric(20)

      user.update!(authentication_token:)

      render json: { authentication_token: }
    else
      render json: { error: "invalid_credentials" }, status: 422
    end
  end
end
