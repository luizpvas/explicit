# frozen_string_literal: true

module Explicit
  extend self

  class Config
    def request_examples_file_path=(path)
      @request_examples_file_path = path
    end

    def request_examples_file_path
      @request_examples_file_path ||= ::Rails.root&.join("public/explicit_request_examples.json")
    end

    def request_examples_persistance_enabled?
      ENV["EXPLICIT_PERSIST_EXAMPLES"].in? %w[true 1 on]
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

  attr_reader :config
  @config = Config.new

  def configure(&block)
    block.call(@config)
  end
end