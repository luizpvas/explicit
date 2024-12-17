# frozen_string_literal: true

module Schema
  class API
    class Engine < ::Rails::Engine
      isolate_namespace Schema::API
    end
  end
end
