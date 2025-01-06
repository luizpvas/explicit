# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateTimeISO8601Test < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      Time.new(2024, 12, 10, 14, 21, 0, 0),
      validate("2024-12-10T14:21:00Z", :date_time_iso8601)
    )
  end

  test "error" do
    assert_error "must be a valid iso8601 date time", validate(nil, :date_time_iso8601)
    assert_error "must be a valid iso8601 date time", validate("foo", :date_time_iso8601)
    assert_error "must be a valid iso8601 date time", validate(1733844129, :date_time_iso8601)
  end

  test "swagger" do
    type = type([:description, "hello", :date_time_iso8601])

    assert_equal type.swagger_schema, {
      type: "string",
      format: "date-time",
      description: "hello\n\n* Must be valid according to ISO 8601"
    }
  end
end