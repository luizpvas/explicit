# frozen_string_literal: true

module API::V1
  Documentation = Explicit::Documentation.new do
    page_title "Acme API"

    section "Introduction" do
      add title: "About", partial: "api/v1/introduction"
    end

    section "Auth" do
      add API::V1::RegistrationsController::CreateRequest
      add API::V1::SessionsController::CreateRequest
      add API::V1::SessionsController::DestroyRequest
    end
  end
end
