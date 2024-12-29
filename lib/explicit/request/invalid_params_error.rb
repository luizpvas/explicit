# frozen_string_literal: true

class Explicit::Request::InvalidParamsError < ::RuntimeError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end

  module Rescuer
    extend ::ActiveSupport::Concern

    included do
      rescue_from Explicit::Request::InvalidParamsError do |err|
        params = Explicit::Spec::Error.translate(err.errors)

        render json: { error: "invalid_params", params: }, status: 422
      end
    end
  end
end
