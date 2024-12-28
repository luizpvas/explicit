# frozen_string_literal: true

require "rails_helper"

describe API::V1::RegistrationsController, type: :request do
  context "POST /api/v1/registrations" do
    before { freeze_time }

    it "registers a new user" do
      response = fetch(
        API::V1::RegistrationsController::CreateRequest,
        params: {
          name: "Yukihiro Matsumoto",
          email_address: "matz@ruby.org",
          password: "mystrongpassword",
          terms_of_use: true
        },
        save_as_example: true
      )

      expect(response.status).to eql(200)

      Token.find_by!(value: response.data[:token]).tap do |token|
        expect(token.purpose).to eql("authentication")
        expect(token.expires_at).to eql(30.days.from_now)
        expect(token.revoked_at).to be_nil
      end
    end

    it "responds with :email_already_token" do
      response = fetch(
        API::V1::RegistrationsController::CreateRequest,
        params: {
          name: "Luiz",
          email_address: "luiz@example.org",
          password: "mystrongpassword",
          terms_of_use: true
        },
        save_as_example: true
      )

      expect(response.status).to eql(422)
      expect(response.dig(:error)).to eql("email_already_taken")
    end

    it "responds with :invalid_params" do
      response = fetch(
        API::V1::RegistrationsController::CreateRequest,
        params: {},
        save_as_example: true
      )

      expect(response.status).to eql(422)

      expect(response.data).to eql({
        error: "invalid_params",
        params: {
          name: "must be a string",
          email_address: "must be a string",
          password: "must be a string",
          terms_of_use: "must be accepted"
        }
      })
    end
  end
end