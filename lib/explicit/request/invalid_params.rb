# frozen_string_literal: true

module Explicit::Request::InvalidParams
  class Error < ::RuntimeError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end
  end

  module Handler
    extend ::ActiveSupport::Concern

    included do
      rescue_from Error do |err|
        params = Explicit::Spec::Error.translate(err.errors)

        render json: { error: "invalid_params", params: }, status: 422
      end
    end
  end
end
