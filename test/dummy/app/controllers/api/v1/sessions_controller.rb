# frozen_string_literal: true

class API::V1::SessionsController < API::V1::BaseController
  before_action :authenticate_request!, only: :destroy

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

  def destroy
    current_token.revoke

    render json: { message: "session revoked" }
  end
end
