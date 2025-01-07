# frozen_string_literal: true

require "test_helper"

class Explicit::Type::BigdecimalTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok BigDecimal("1"), validate("1", :big_decimal)
    assert_ok BigDecimal("-1"), validate("-1", :big_decimal)
    assert_ok BigDecimal("1.0"), validate("1.0", :big_decimal)
    assert_ok BigDecimal("1"), validate(1, :big_decimal)
  end

  test "min" do
    assert_ok BigDecimal("1"), validate("1", [:big_decimal, min: 1])

    assert_error "must be at least 1", validate("0", [:big_decimal, min: 1])
  end

  test "max" do
    assert_ok BigDecimal("1"), validate("1", [:big_decimal, max: 1])

    assert_error "must be at most 1", validate("2", [:big_decimal, max: 1])
  end

  test "error" do
    assert_error "must be a string-encoded decimal number", validate("foo", :big_decimal)
    assert_error "must be a string-encoded decimal number", validate(2.0, :big_decimal)
    assert_error "must be a string-encoded decimal number", validate(true, :big_decimal)
    assert_error "must be a string-encoded decimal number", validate([10], :big_decimal)
    assert_error "must be a string-encoded decimal number", validate(nil, :big_decimal)
  end

  test "swagger" do
    type = type([:description, "hello", [:big_decimal, min: 0, max: 10]])

    assert_equal type.swagger_schema, {
      type: "string",
      pattern: /^\d*\.?\d*$/.inspect,
      format: "decimal number",
      description: "hello\n\n* Minimum: 0\n* Maximum: 10"
    }
  end
end