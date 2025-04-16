# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateTimeISO8601RangeTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      Range.new("2025-01-08T10:00:00".to_datetime, "2025-01-08T12:00:00".to_datetime),
      validate("2025-01-08T10:00:00Z..2025-01-08T12:00:00Z", :date_time_iso8601_range)
    )
  end
  
  test "min_range" do
    assert_ok(
      Range.new("2025-01-08T10:00:00".to_datetime, "2025-01-08T12:00:00".to_datetime),
      validate("2025-01-08T10:00:00Z..2025-01-08T12:00:00Z", [:date_time_iso8601_range, min_range: 2.hours])
    )

    assert_error(
      "must not be less than 2 hours",
      validate("2025-01-08T10:00:00Z..2025-01-08T11:59:00Z", [:date_time_iso8601_range, min_range: 2.hours])
    )
  end

  test "max_range" do
    assert_ok(
      Range.new("2025-01-08T10:00:00".to_datetime, "2025-01-09T10:00:00".to_datetime),
      validate("2025-01-08T10:00:00Z..2025-01-09T10:00:00Z", [:date_time_iso8601_range, max_range: 1.day])
    )

    assert_error(
      "must not be more than 1 day",
      validate("2025-01-08T10:00:00Z..2025-01-09T10:01:00Z", [:date_time_iso8601_range, max_range: 1.day])
    )
  end

  test "min_date_time" do
    assert_ok(
      Range.new("2025-01-08T10:00:00".to_datetime, "2025-01-08T12:00:00".to_datetime),
      validate("2025-01-08T10:00:00Z..2025-01-08T12:00:00Z", [:date_time_iso8601_range, min_date_time: -> { "2025-01-08T10:00:00".to_datetime }])
    )

    assert_error(
      'starting datetime must not be a moment before 2025-01-08T10:00:00+00:00',
      validate("2025-01-08T09:00:00Z..2025-01-08T12:00:00Z", [:date_time_iso8601_range, min_date_time: "2025-01-08T10:00:00".to_datetime])
    )
  end

  test "max_date_time" do
    assert_ok(
      Range.new("2025-01-08T10:00:00".to_datetime, "2025-01-08T12:00:00".to_datetime),
      validate("2025-01-08T10:00:00Z..2025-01-08T12:00:00Z", [:date_time_iso8601_range, max_date_time: -> { "2025-01-08T12:00:00".to_datetime }])
    )

    assert_error(
      'ending datetime must not be a moment after 2025-01-08T12:00:00+00:00',
      validate("2025-01-08T09:00:00Z..2025-01-08T12:01:00Z", [:date_time_iso8601_range, max_date_time: "2025-01-08T12:00:00".to_datetime])
    )
  end

  test "error" do
    assert_error "must be a string", validate(nil, :date_time_iso8601_range)

    assert_error(
      'must be a string in the format of: "YYYY-MM-DDTHH:MM:SS..YYYY-MM-DDTHH:MM:SS"',
      validate("foo", :date_time_iso8601_range)
    )

    assert_error(
      'must be a string in the format of: "YYYY-MM-DDTHH:MM:SS..YYYY-MM-DDTHH:MM:SS"',
      validate("2025-01-08T10:00:00Z..bar", :date_time_iso8601_range)
    )

    assert_error(
      'must be a string in the format of: "YYYY-MM-DDTHH:MM:SS..YYYY-MM-DDTHH:MM:SS"',
      validate("foo..2025-01-08T10:00:00Z", :date_time_iso8601_range)
    )

    assert_error(
      "starting datetime must be a moment before ending datetime",
      validate("2025-01-08T12:00:00Z..2025-01-08T09:00:00Z", :date_time_iso8601_range)
    )
  end

  test "json_schema" do
    type = type([:date_time_iso8601_range, min_range: 1.day, max_range: 30.days])

    assert_equal type.json_schema(nil), {
      type: "string",
      format: "date time range",
      description_topics: [
        "* The value must be a range between two date times in the format of: \"YYYY-MM-DDTHH:MM:SS..YYYY-MM-DDTHH:MM:SS\"",
        "* The range must not be less than 1 day",
        "* The range must not be more than 30 days"
      ]
    }
  end
end
