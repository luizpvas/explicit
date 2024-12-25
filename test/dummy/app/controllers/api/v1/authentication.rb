# frozen_string_literal: true

module API::V1::Authentication
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user, :current_token
  end
  
  Request = Explicit::Request.new do
    header "Authorization", [:string, format: /[a-zA-Z0-9]{20}/]

    response 403, { error: "unauthorized" }
  end

  def authenticate_request!
    bearer = request.headers["Authorization"]&.split(" ")&.last

    return render json: { error: "unauthorized" }, status: 403 if bearer.blank?

    token = Token.active.find_by(value: bearer)

    return render json: { error: "unauthorized" }, status: 403 if token.blank?

    @current_token = token
    @current_user = token.user
  end
end