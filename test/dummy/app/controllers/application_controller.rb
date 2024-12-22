class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Schema::API::InvalidParamsError do |err|
    errors = Schema::API::Errors.translate(err.errors, I18n.method(:t))

    render json: { error: "invalid_params", errors: }, status: 422
  end
end
