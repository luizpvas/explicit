# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::BigdecimalTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok BigDecimal("1"), validate("1", :bigdecimal)
    assert_ok BigDecimal("-1"), validate("-1", :bigdecimal)
    assert_ok BigDecimal("1.0"), validate("1.0", :bigdecimal)
    assert_ok BigDecimal("1"), validate(1, :bigdecimal)
  end

  test "min" do
    assert_ok BigDecimal("1"), validate("1", [:bigdecimal, min: 1])

    assert_error [:min, 1], validate("0", [:bigdecimal, min: 1])
  end

  test "max" do
    assert_ok BigDecimal("1"), validate("1", [:bigdecimal, max: 1])

    assert_error [:max, 1], validate("2", [:bigdecimal, max: 1])
  end

  test "error" do
    assert_error :bigdecimal, validate("foo", :bigdecimal)
    assert_error :bigdecimal, validate(2.0, :bigdecimal)
    assert_error :bigdecimal, validate(true, :bigdecimal)
    assert_error :bigdecimal, validate([10], :bigdecimal)
    assert_error :bigdecimal, validate(nil, :bigdecimal)
  end
end