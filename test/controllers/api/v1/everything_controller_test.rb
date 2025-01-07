# frozen_string_literal: true

require "test_helper"

class API::V1::EverythingControllerTest < ActionDispatch::IntegrationTest
  test "responds with success" do
    response = fetch(
      API::V1::EverythingController::Request,
      params: {
        file1: file_fixture_upload("this_is_fine.png", "image/png"),
        string1: "hello#'\"",
        integer1: 42,
        hash1: {
          "key1" => [1, 2, 3],
          "key2" => [4, 5, 6]
        },
        agreement1: true,
        big_decimal1: "10.5",
        boolean1: true,
        date_time_iso8601: "2021-01-01T12:00:00Z",
        date_time_posix: 1609459200,
        enum1: "one"
      },
      save_as_example: true
    )

    assert_equal 200, response.status
  end
end