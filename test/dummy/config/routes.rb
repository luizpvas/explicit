Rails.application.routes.draw do
  scope "/api/v1", module: "api/v1" do
    resources :registrations, only: %i[create]
    resources :sessions, only: %i[create]
  end

  mount API::V1::Documentation => "/api/v1/docs"
end
