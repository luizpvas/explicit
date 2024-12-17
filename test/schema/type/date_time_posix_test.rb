# frozen_string_literal: true

require "test_helper"

class Schema::Type::DateTimePosixTest < ActiveSupport::TestCase
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

  test "error" do
    assert_error :date_time_posix, validate("foo", :date_time_posix)
    assert_error :date_time_posix, validate(nil, :date_time_posix)
  end
end
