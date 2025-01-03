# frozen_string_literal: true

require "test_helper"

class Explicit::Request::Example::CurlTest < ActiveSupport::TestCase
  test "curl request without headers, body and path params" do
    request = Explicit::Request.new do
      base_url "htpt://localhost:300"
      get "/api"

      response 200, {}

      add_example(
        params: {},
        headers: {},
        response: {
          status: 200,
          data: {}
        }
      )
    end

    assert_equal request.examples[200].first.to_curl, <<~BASH
      curl -XGET "http://localhost:3000/api"
    BASH
  end
end
