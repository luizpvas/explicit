# frozen_string_literal: true

require "test_helper"

class Schema::API::RequestValidationTest < ActiveSupport::TestCase
  class Schema < Schema::API
    param :title, [:string, empty: false]
    param :published_at, :date_time_iso8601
  end

  test "valid params" do
    params = {
      title: "Title",
      published_at: "2024-12-18T13:49:24Z"
    }

    expected_validated_data = {
      title: "Title",
      published_at: ::Time.iso8601("2024-12-18T13:49:24Z")
    }

    assert_equal expected_validated_data, Schema.validate!(params)
  end

  test "invalid params" do
    assert_raises ::Schema::API::InvalidParamsError do
      Schema.validate!({})
    end
  end
end
