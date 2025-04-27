# frozen_string_literal: true

module Explicit
  extend self

  class Configuration
    def initialize
      @rescue_from_invalid_params = true
      @cors_enabled = !defined?(::Rack::Cors)
    end

    def request_examples_file_path=(path)
      @request_examples_file_path = path
    end

    def request_examples_file_path
      @request_examples_file_path ||= ::Rails.root&.join("public/explicit_request_examples.json")
    end

    def request_examples_persistance_enabled?
      ENV["UPDATE_REQUEST_EXAMPLES"].in? %w[true 1 on ok]
    end

    def rescue_from_invalid_params=(enabled)
      @rescue_from_invalid_params = enabled
    end

    def rescue_from_invalid_params?
      @rescue_from_invalid_params
    end

    def raise_on_invalid_example=(enabled)
      @raise_on_invalid_example = enabled
    end

    def raise_on_invalid_example?
      @raise_on_invalid_example
    end

    def cors_enabled=(enabled)
      @cors_enabled = enabled
    end

    def cors_enabled?
      @cors_enabled
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
