class ApplicationController < ActionController::API
  rescue_from Schemax::Request::InvalidParamsError do |err|
    params = Schemax::Spec::Error.translate(err.errors)

    render json: { error: "invalid_params", params: }, status: 422
  end
end
