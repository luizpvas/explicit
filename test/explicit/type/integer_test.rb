# frozen_string_literal: true

require "test_helper"

class Explicit::Type::IntegerTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok 10, validate(10, :integer)
    assert_ok(-1, validate(-1, :integer))
  end

  test "parse" do
    assert_ok 1, validate("1", [:integer, parse: true])
    assert_ok(-1, validate("-1", [:integer, parse: true]))

    assert_error "must be an integer", validate("foo", [:integer, parse: true])
  end

  test "min max" do
    assert_ok 1, validate(1, [:integer, min: 1, max: 2])
    assert_ok 2, validate(2, [:integer, min: 1, max: 2])

    assert_error "must be at least 1", validate(0, [:integer, min: 1, max: 2])
    assert_error "must be at most 2", validate(3, [:integer, min: 1, max: 2])
  end

  test "negative" do
    assert_ok(-1, validate(-1, [:integer, negative: true]))

    assert_error "must not be negative", validate(-1, [:integer, negative: false])
  end


  test "positive" do
    assert_ok 1, validate(1, [:integer, positive: true])

    assert_error "must not be positive", validate(1, [:integer, positive: false])
  end

  test "error" do
    assert_error "must be an integer", validate(nil, :integer)
    assert_error "must be an integer", validate("foo", :integer)
    assert_error "must be an integer", validate([], :integer)
    assert_error "must be an integer", validate({}, :integer)
    assert_error "must be an integer", validate(9.5, :integer)
  end
end
