# frozen_string_literal: true

class Schemax::Engine < ::Rails::Engine
  initializer "schemax.rescue_from_invalid_params" do
    ActiveSupport.on_load(:action_controller_api) do
      include Schemax::Request::InvalidParams::Handler
    end
  end
end
