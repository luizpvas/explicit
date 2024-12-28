# frozen_string_literal: true

require "test_helper"

class Explicit::Request::ExamplesTest < ActiveSupport::TestCase
  test "adds an example to the request" do
    request = Explicit::Request.new do
      param :name, :string
      response 200, { name: :string }

      add_example(
        params: { name: "Luiz" },
        response: { status: 200, data: { name: "Luiz" } }
      )
    end

    assert_equal 1, request.examples.size

    request.examples.first.tap do |example|
      assert_equal example.params, { name: "Luiz" }
      assert_equal example.headers, {}
      assert_equal Explicit::Request::Response.new(200, { name: "Luiz" }), example.response
    end
  end

  test "raises an error if example does not match param specs" do
    assert_raises Explicit::Request::InvalidExampleError do
      Explicit::Request.new do
        param :name, :string
        response 200, {}

        add_example(
          params: { name: 10 },
          response: { status: 200, data: {} }
        )
      end
    end
  end

  test "raises an error if example does not match header specs" do
    assert_raises Explicit::Request::InvalidExampleError do
      Explicit::Request.new do
        header "Authorization", :string
        response 200, {}

        add_example(
          params: {},
          response: { status: 200, data: {} }
        )
      end
    end
  end

  test "raises an error if example does not match response specs" do
    assert_raises Explicit::Request::InvalidExampleError do
      Explicit::Request.new do
        response 200, {}

        add_example(
          params: {},
          response: { status: 201, data: {} }
        )
      end
    end
  end
end