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

    assert_error "must be at least 1", validate("0", [:bigdecimal, min: 1])
  end

  test "max" do
    assert_ok BigDecimal("1"), validate("1", [:bigdecimal, max: 1])

    assert_error "must be at most 1", validate("2", [:bigdecimal, max: 1])
  end

  test "error" do
    assert_error "must be a string-encoded decimal number", validate("foo", :bigdecimal)
    assert_error "must be a string-encoded decimal number", validate(2.0, :bigdecimal)
    assert_error "must be a string-encoded decimal number", validate(true, :bigdecimal)
    assert_error "must be a string-encoded decimal number", validate([10], :bigdecimal)
    assert_error "must be a string-encoded decimal number", validate(nil, :bigdecimal)
  end
end