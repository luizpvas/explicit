# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateTimePosixTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      DateTime.new(2024, 12, 11, 11, 37, 43, 0),
      validate(1733917063, :date_time_posix)
    )

    assert_ok(
      DateTime.new(2024, 12, 11, 11, 37, 43, 0),
      validate("1733917063", :date_time_posix)
    )
  end

  test "min" do
    assert_ok(
      "2024-12-11 11:37:43".to_datetime,
      validate(1733917063, [:date_time_posix, min: -> { "2024-12-11 11:37:43".to_datetime }])
    )

    assert_error(
      "must not be a moment before 2024-12-11T11:37:43+00:00",
      validate(1733917062, [:date_time_posix, min: -> { "2024-12-11 11:37:43".to_datetime }])
    )
  end

  test "max" do
    assert_ok(
      "2024-12-11 11:37:43".to_datetime,
      validate(1733917063, [:date_time_posix, max: -> { "2024-12-11 11:37:43".to_datetime }])
    )

    assert_error(
      "must not be a moment after 2024-12-11T11:37:43+00:00",
      validate(1733917064, [:date_time_posix, max: -> { "2024-12-11 11:37:43".to_datetime }])
    )
  end

  test "error" do
    assert_error "must be a valid posix timestamp", validate("foo", :date_time_posix)
    assert_error "must be a valid posix timestamp", validate(nil, :date_time_posix)
  end

  test "swagger" do
    type = type([
      :description,
      "hello",
      [:default, 1733917063, :date_time_posix]
    ])

    assert_equal type.swagger_schema, {
      type: "integer",
      minimum: 1,
      format: "POSIX time",
      default: 1733917063,
      description: "hello\n\n* POSIX time or Unix epoch is the amount of seconds since 1970-01-01"
    }
  end
end
