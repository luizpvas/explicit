# frozen_string_literal: true

module Explicit::Documentation::Output
  class Swagger
    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    def call
      raise NotImplementedError
    end
  end
end
