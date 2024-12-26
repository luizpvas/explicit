# frozen_string_literal: true

module API::V1
  Documentation = Explicit::Documentation.build do
    page_title "Acme API"
    primary_color "#6366f1"

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
