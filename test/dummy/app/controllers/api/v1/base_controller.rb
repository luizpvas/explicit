# frozen_string_literal: true

class API::V1::BaseController < ActionController::API
  include API::V1::Authentication
end
