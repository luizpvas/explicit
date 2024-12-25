# frozen_string_literal: true

class Explicit::Engine < ::Rails::Engine
  initializer "explicit.rescue_from_invalid_params" do
    ActiveSupport.on_load(:action_controller_api) do
      include Explicit::Request::InvalidParams::Handler
    end
  end
end
