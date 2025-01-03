# frozen_string_literal: true

require "test_helper"

class Explicit::Type::StringTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "foo", validate("foo", :string)
    assert_ok "foo", validate("foo", :string)
    assert_ok "bar", validate("bar", :string)
    assert_ok "1",   validate("1", :string)
    assert_ok "1.0", validate("1.0", :string)
    assert_ok "",    validate("", :string)
  end

  test "strip" do
    assert_ok "foo", validate(" foo ", [:string, strip: true])
    assert_ok " foo ", validate(" foo ", [:string, strip: false])
  end

  test "empty" do
    assert_ok "foo", validate("foo", [:string, empty: false])
    assert_ok "", validate("", [:string, empty: true])

    assert_error "must not be empty", validate("", [:string, empty: false])
    assert_error "must not be empty", validate("  ", [:string, empty: false, strip: true])
  end

  test "minlength" do
    assert_ok "foo", validate("foo", [:string, minlength: 3])
    assert_ok "", validate("", [:string, minlength: 0])

    assert_error "length must be at least 4", validate("foo", [:string, minlength: 4])
  end

  test "maxlength" do
    assert_ok "foo", validate("foo", [:string, maxlength: 3])
    assert_ok "", validate("", [:string, maxlength: 0])

    assert_error "length must be at most 2", validate("foo", [:string, maxlength: 2])
  end

  test "format" do
    assert_ok "foo", validate("foo", [:string, format: /(foo|bar)/])
    assert_ok "bar", validate("bar", [:string, format: /(foo|bar)/])

    assert_error "must have format /(foo|bar)/", validate("qux", [:string, format: /(foo|bar)/])
  end

  test "case_sensitive" do
    assert_ok "FOO", validate("FOO", [:string, downcase: false])
    assert_ok "foo", validate("FOO", [:string, downcase: true])
  end

  test "error" do
    assert_error "must be a string", validate(1, :string)
    assert_error "must be a string", validate(1.0, :string)
    assert_error "must be a string", validate(:symbol, :string)
    assert_error "must be a string", validate([], :string)
    assert_error "must be a string", validate(nil, :string)
  end
end
