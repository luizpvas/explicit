class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Schema::API::InvalidParamsError do |err|
    render json: err.errors, status: 422
  end
end
