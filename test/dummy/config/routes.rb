Rails.application.routes.draw do
  mount Schema::API::Engine => "/schema-api"
end
