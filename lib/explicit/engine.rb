# frozen_string_literal: true

class Explicit::Engine < ::Rails::Engine
  initializer "explicit.rescue_from_invalid_params" do
    if Explicit.configuration.rescue_from_invalid_params?
      ActiveSupport.on_load(:action_controller_api) do
        include Explicit::Request::InvalidParamsError::Rescuer
      end
    end
  end
end
