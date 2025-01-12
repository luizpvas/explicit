# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateTimeISO8601Test < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      "2024-12-10 14:21:00".to_datetime,
      validate("2024-12-10T14:21:00Z", :date_time_iso8601)
    )
  end

  test "min" do
    assert_ok(
      "2024-12-10 14:21:00".to_datetime,
      validate("2024-12-10T14:21:00Z", [:date_time_iso8601, min: "2024-12-10 14:21:00".to_datetime])
    )

    assert_error(
      "must not be a moment before 2024-12-10T14:21:00+00:00",
      validate("2024-12-10T14:20:00Z", [:date_time_iso8601, min: -> { "2024-12-10 14:21:00".to_datetime }])
    )
  end

  test "max" do
    assert_ok(
      "2024-12-10 14:21:00".to_datetime,
      validate("2024-12-10T14:21:00Z", [:date_time_iso8601, max: "2024-12-10 14:21:00".to_datetime])
    )

    assert_error(
      "must not be a moment after 2024-12-10T14:21:00+00:00",
      validate("2024-12-10T14:22:00Z", [:date_time_iso8601, max: -> { "2024-12-10 14:21:00".to_datetime }])
    )
  end

  test "error" do
    assert_error "must be a valid datetime according to ISO8601", validate(nil, :date_time_iso8601)
    assert_error "must be a valid datetime according to ISO8601", validate("foo", :date_time_iso8601)
    assert_error "must be a valid datetime according to ISO8601", validate(1733844129, :date_time_iso8601)
  end

  test "swagger" do
    type = type([
      :description,
      "hello",
      [:default, "2024-12-10T14:21:00Z", :date_time_iso8601]
    ])

    assert_equal type.swagger_schema, {
      type: "string",
      format: "date-time",
      default: "2024-12-10T14:21:00Z",
      description: "hello\n\n* Must be valid according to ISO 8601"
    }
  end
end