module Schema
  module API
    class Engine < ::Rails::Engine
      isolate_namespace Schema::API
    end
  end
end
