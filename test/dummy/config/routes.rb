Rails.application.routes.draw do
  resources :sessions, only: %i[create]

  mount API::V1::Documentation => "/api/v1/docs"
end
