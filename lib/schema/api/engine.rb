module Schema
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace Schema::Api
    end
  end
end
