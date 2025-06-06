# frozen_string_literal: true

require "test_helper"

class Explicit::Type::TestBoolean < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :boolean)
    assert_ok true, validate("true", :boolean)
    assert_ok true, validate("1", :boolean)
    assert_ok true, validate("on", :boolean)
    assert_ok true, validate(1, :boolean)

    assert_ok false, validate(false, :boolean)
    assert_ok false, validate("false", :boolean)
    assert_ok false, validate("0", :boolean)
    assert_ok false, validate("off", :boolean)
    assert_ok false, validate(0, :boolean)
  end

  test "error" do
    assert_error "must be a boolean", validate(nil, :boolean)
    assert_error "must be a boolean", validate(10, :boolean)
    assert_error "must be a boolean", validate("foo", :boolean)
    assert_error "must be a boolean", validate([], :boolean)
  end

  test "json_schema" do
    type = type(:boolean)

    assert_equal type.json_schema(nil), { type: "boolean", }
  end
end
