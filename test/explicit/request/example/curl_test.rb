# frozen_string_literal: true

require "test_helper"

class Explicit::Request::Example::CurlTest < ActiveSupport::TestCase
  test "curl request without headers, body and path params" do
    request = Explicit::Request.new do
      base_url "http://localhost:3000"
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

    assert_equal request.examples[200].first.to_curl_lines, [
      'curl -XGET "http://localhost:3000/api"'
    ]
  end

  test "curl request with headers" do
    request = Explicit::Request.new do
      base_url "http://localhost:3000"
      get "/api"

      response 200, {}

      add_example(
        params: {},
        headers: { "Authorization" => "Bearer abcd-1234" },
        response: {
          status: 200,
          data: {}
        }
      )
    end

    assert_equal request.examples[200].first.to_curl_lines, [
      'curl -XGET "http://localhost:3000/api"',
      '-H "Authorization: Bearer abcd-1234"'
    ]
  end

  test "curl request with headers and body" do
    request = Explicit::Request.new do
      base_url "http://localhost:3000"
      get "/api"

      response 200, {}

      add_example(
        params: { key: "value" },
        headers: { "Authorization" => "Bearer abcd-1234" },
        response: {
          status: 200,
          data: {}
        }
      )
    end

    assert_equal request.examples[200].first.to_curl_lines, [
      'curl -XGET "http://localhost:3000/api"',
      '-H "Content-Type: application/json"',
      '-H "Authorization: Bearer abcd-1234"',
      "-d '#{JSON.pretty_generate(request.examples[200].first.params)}'"
    ]
  end

  test "curl request with path params" do
    request = Explicit::Request.new do
      base_url "http://localhost:3000"
      get "/api/:id"

      response 200, {}

      add_example(
        params: { id: "10" },
        headers: { "Authorization" => "Bearer abcd-1234" },
        response: {
          status: 200,
          data: {}
        }
      )
    end

    assert_equal request.examples[200].first.to_curl_lines, [
      'curl -XGET "http://localhost:3000/api/10"',
      '-H "Authorization: Bearer abcd-1234"'
    ]
  end

  test "curl request with file upload" do
    request = Explicit::Request.new do
      base_url "http://localhost:3000"
      post "/api"

      param :name, :string
      param :file, :file

      response 200, {}

      add_example(
        params: { name: "foo", file: "@my_file.png" },
        response: { status: 200,  data: {} }
      )
    end

    assert_equal request.examples[200].first.to_curl_lines, [
      'curl -XPOST "http://localhost:3000/api"',
      '-H "Content-Type: multipart/form-data"',
      '-F "name=foo"',
      '-F file="@my_file.png"'
    ]
  end
end
