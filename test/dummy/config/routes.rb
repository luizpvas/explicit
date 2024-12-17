Rails.application.routes.draw do
  mount Schema::Api::Engine => "/schema-api"
end
