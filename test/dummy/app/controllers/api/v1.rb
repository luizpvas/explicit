# frozen_string_literal: true

class API::V1 < Schema::API::Documentation
  section "Introduction" do
    add partial: "api/v1/introduction"
  end

  section "Auth" do
    add API::V1::SessionsController::CreateSchema
    add API::V1::RegistrationsController::CreateSchema
  end

  section "Posts" do
    add API::V1::PostsController::CreateSchema
    add API::V1::PostsController::UpdateSchema
    add API::V1::PostsController::DestroySchema
  end
end
