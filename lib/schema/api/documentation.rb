# frozen_string_literal: true

module Schema::API::Documentation
  class Builder
    def section(name)
    end

    def add(**opts)
    end

    def call(request)
      response = ["Hello, world!"]

      [200, {}, response]
    end
  end

  def self.publish(&block)
    builder = Builder.new

    ::Class.new(::Rails::Engine).tap do |engine|
      engine.routes.draw { root to: builder }
    end
  end
end
