# frozen_string_literal: true

class API::V1::EverythingController < API::V1::BaseController
  CreateRequest = API::V1::Request.new do
    post "/everything"

    description <<~MD
      This endpoint uses all available features in the Explicit gem.
    MD
  end
  
  def create
  end
end
