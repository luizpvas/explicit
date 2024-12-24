# frozen_string_literal: true

require "test_helper"

class Schemax::Spec::TestBoolean < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :boolean)
    assert_ok false, validate(false, :boolean)
  end

  test "parse" do
    assert_ok true, validate("true", [:boolean, parse: true])
    assert_ok true, validate("1", [:boolean, parse: true])
    assert_ok true, validate("on", [:boolean, parse: true])

    assert_ok false, validate("false", [:boolean, parse: true])
    assert_ok false, validate("0", [:boolean, parse: true])
    assert_ok false, validate("off", [:boolean, parse: true])
  end

  test "error" do
    assert_error :boolean, validate(nil, :boolean)
    assert_error :boolean, validate(10, :boolean)
    assert_error :boolean, validate("foo", :boolean)
    assert_error :boolean, validate([], :boolean)
  end
end
