# frozen_string_literal: true

module API::V1
  Documentation = Explicit::Documentation.new do
    page_title "Acme API"
    company_logo_url "https://raw.githubusercontent.com/luizpvas/explicit/refs/heads/main/assets/logo.svg"
    favicon_url "https://github.githubassets.com/favicons/favicon.svg"
    version "1.0.1"

    section "Introduction" do
      add title: "About", partial: "api/v1/introduction"
    end

    section "Auth" do
      add API::V1::RegistrationsController::CreateRequest
      add API::V1::SessionsController::CreateRequest
      add API::V1::SessionsController::DestroyRequest
    end

    section "Articles" do
      add API::V1::ArticlesController::IndexRequest
      add API::V1::ArticlesController::CreateRequest
      add API::V1::ArticlesController::ShowRequest
      add API::V1::ArticlesController::UpdateRequest
    end

    section "Others" do
      add API::V1::EverythingController::Request
    end
  end
end
