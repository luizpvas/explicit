# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServer::BuilderTest < ::ActiveSupport::TestCase
  class FakeRouter
    attr_reader :request

    def initialize
      @request = nil
    end

    def handle(request)
      @request = request

      "fake"
    end
  end

  test "authorize with custom headers" do
    builder = ::Explicit::MCPServer::Builder.new
    fake_router = FakeRouter.new

    builder.define_singleton_method(:authorize) do |**|
      proxy_with(headers: { "Foo" => "Bar" })
    end

    builder.define_singleton_method(:router) { fake_router }

    response = builder.call({ "rack.input" => StringIO.new("{}") })

    assert_equal 200, response[0]
    assert_equal "application/json", response[1]["Content-Type"]
    assert_equal '"fake"', response[2].first

    assert_equal({ "Foo" => "Bar" }, fake_router.request.headers)
  end

  test "authorize without headers" do
    builder = ::Explicit::MCPServer::Builder.new
    fake_router = FakeRouter.new

    builder.define_singleton_method(:authorize) { |**| true }
    builder.define_singleton_method(:router) { fake_router }

    response = builder.call({ "rack.input" => StringIO.new("{}") })

    assert_equal 200, response[0]
    assert_equal "application/json", response[1]["Content-Type"]
    assert_equal '"fake"', response[2].first

    assert_equal({}, fake_router.request.headers)
  end

  test "rejects unauthorized requests" do
    builder = ::Explicit::MCPServer::Builder.new
    fake_router = FakeRouter.new

    builder.define_singleton_method(:authorize) { |**| false }
    builder.define_singleton_method(:router) { fake_router }

    response = builder.call({ "rack.input" => StringIO.new("{}") })

    assert_equal 403, response[0]
    assert_equal({}, response[1])
    assert_equal [], response[2]

    assert_nil fake_router.request
  end
end
