# frozen_string_literal: true

require "test_helper"

class Explicit::Request::InvalidParamsTest < ActiveSupport::TestCase
  test "default invalid params response" do
    request = Explicit::Request.new do
      param :name, :string
    end

    assert_equal request.responses[422].first, {
      error: "invalid_params",
      params: [
        :description,
        "An object containing error messages for all invalid params",
        [:hash, :string, :string]
      ]
    }
  end

  test "does not add invalid params response if request accepts no headers or params" do
    request = Explicit::Request.new { }

    assert_equal [], request.responses[422]
  end
end