# frozen_string_literal: true

class API::V1::RegistrationsController < API::V1::BaseController
  CreateRequest = API::V1::Request.new do
    post "/registrations"

    title "Registration"

    description <<~MD
    Attempts to register a new user in the system. Email address must be unique.
    If registration succeeds an authentication token is returned. Use this token
    to authenticate requests with the header `Authorization: Bearer <token>`.
    MD

    param :name,
      [:string, empty: false],
      description: "Full name"

    param :email_address,
      [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true, downcase: true],
      description: "Email address used to login. Case insensitive."

    param :password,
      [:string, min_length: 8],
      description: "Minimum 8 characters. No other rules."

    param :terms_of_use, :agreement

    response 200, { token: :string }
    response 422, { error: "email_already_taken" }
  end

  def create
    CreateRequest.validate!(params) => { name:, email_address:, password: }

    user = User.create!(name:, email_address:, password:)

    token = user.tokens.authentication.create!(
      expires_at: 30.days.from_now,
      ip_address: request.ip,
      user_agent: request.user_agent
    )

    render json: { token: token.value }
  rescue ActiveRecord::RecordNotUnique
    render json: { error: "email_already_taken" }, status: 422
  end
end
