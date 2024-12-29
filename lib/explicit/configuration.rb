# frozen_string_literal: true

module Explicit
  extend self

  class Configuration
    def initialize
      @rescue_from_invalid_params = true
    end

    def request_examples_file_path=(path)
      @request_examples_file_path = path
    end

    def request_examples_file_path
      @request_examples_file_path ||= ::Rails.root&.join("public/explicit_request_examples.json")
    end

    def request_examples_persistance_enabled?
      ENV["EXPLICIT_PERSIST_EXAMPLES"].in? %w[true 1 on]
    end

    def rescue_from_invalid_params=(enabled)
      @rescue_from_invalid_params = enabled
    end

    def rescue_from_invalid_params?
      @rescue_from_invalid_params
    end

    def test_runner=(test_runner)
      @test_runner = test_runner
    end

    def test_runner
      @test_runner ||=
        if defined?(::RSpec) && ::RSpec.respond_to?(:configure)
          :rspec
        else
          :minitest
        end
    end
  end

  attr_reader :configuration
  @configuration = Configuration.new

  def configure(&block)
    block.call(@configuration)
  end
end