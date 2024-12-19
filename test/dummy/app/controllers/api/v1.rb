# frozen_string_literal: true

module API::V1
  Documentation = Schema::API::Documentation.publish do
    section "Introduction" do
      # add title: "About", partial: "api/v1/introduction"
    end

    section "Auth" do
      # add API::V1::SessionsController::CreateRequest
      # add API::V1::RegistrationsController::CreateRequest
    end

    section "Posts" do
      # add API::V1::PostsController::CreateRequest
      # add API::V1::PostsController::CreateRequest
      # add API::V1::PostsController::DestroyRequest
    end
  end
end
