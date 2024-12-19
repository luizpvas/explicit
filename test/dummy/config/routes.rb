Rails.application.routes.draw do
  resources :registrations, only: %i[create]
  resources :sessions, only: %i[create]

  mount API::V1::Documentation => "/api/v1/docs"
end
