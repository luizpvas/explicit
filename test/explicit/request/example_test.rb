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

    request.examples[200].first.tap do |example|
      assert_equal example.params, { name: "Luiz" }
      assert_equal example.headers, {}
      assert_equal Explicit::Request::Response.new(200, { name: "Luiz" }), example.response
    end
  end

  test "raises an error if example does not match response types" do
    ::Explicit.configuration.raise_on_invalid_example = true

    assert_raises Explicit::Request::InvalidResponseError do
      Explicit::Request.new do
        response 200, {}

        add_example(
          params: {},
          response: { status: 201, data: {} }
        )
      end
    end
  ensure
    ::Explicit.configuration.raise_on_invalid_example = false
  end
end
