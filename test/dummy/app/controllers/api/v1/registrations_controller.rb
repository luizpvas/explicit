# frozen_string_literal: true

class API::V1::RegistrationsController < ApplicationController
  class CreateRequest < Schemax::Request
    post "/api/v1/registrations"

    description <<-MD
    Attempts to register a new user in the system. Email address must be unique.
    MD

    param :name, [:string, empty: false]
    param :email_address, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :password, [:string, minlength: 8]
    param :terms_of_use, [:agreement, parse: true]

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
