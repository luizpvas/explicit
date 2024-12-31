# frozen_string_literal: true

require "commonmarker"

module Explicit::Documentation
  extend self

  def new(&block)
    builder = Builder.new.tap { _1.instance_eval &block }

    ::Class.new(::Rails::Engine).tap do |engine|
      engine.routes.draw do
        root to: builder
      end
    end
  end
end
