# frozen_string_literal: true

require "rails_helper"

describe API::V1::SessionsController::CreateRequest, type: :request do
  context "when credentials are valid" do
    it "logs in successfully" do
      response = fetch(
        described_class,
        params: {
          email_address: "luiz@example.org",
          password: "mystrongpassword"
        },
        save_as_example: true
      )

      expect(response.status).to eql(200)
      expect(response.dig(:token)).to be_present
    end
  end

  context "when email_address does not belong to any user" do
    it "responds with invalid_credentials" do
      response = fetch(
        described_class,
        params: {
          email_address: "non-existing-user@example.org",
          password: "any-password"
        },
        save_as_example: true
      )

      expect(response.status).to eql(422)
      expect(response.dig(:error)).to eql("invalid_credentials")
    end
  end
end
