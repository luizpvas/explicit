Rails.application.routes.draw do
  scope "/api/v1", module: "api/v1" do
    resources :registrations, only: %i[create]
    resource :sessions, only: %i[create destroy]
    resources :articles, only: %i[create show update]
    post "/everything", to: "everything#create"
  end

  mount API::V1::Documentation => "/api/v1/docs"
end
