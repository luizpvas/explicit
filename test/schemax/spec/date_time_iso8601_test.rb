# frozen_string_literal: true

require "test_helper"

class Schemax::Spec::DateTimeISO8601Test < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      Time.new(2024, 12, 10, 14, 21, 0, 0),
      validate("2024-12-10T14:21:00Z", :date_time_iso8601)
    )
  end

  test "error" do
    assert_error :date_time_iso8601, validate(nil, :date_time_iso8601)
    assert_error :date_time_iso8601, validate("foo", :date_time_iso8601)
    assert_error :date_time_iso8601, validate(1733844129, :date_time_iso8601)
  end
end