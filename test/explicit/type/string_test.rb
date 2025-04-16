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

  test "min_length" do
    assert_ok "foo", validate("foo", [:string, min_length: 3])
    assert_ok "", validate("", [:string, min_length: 0])

    assert_error "length must be at least 4", validate("foo", [:string, min_length: 4])
  end

  test "max_length" do
    assert_ok "foo", validate("foo", [:string, max_length: 3])
    assert_ok "", validate("", [:string, max_length: 0])

    assert_error "length must be at most 2", validate("foo", [:string, max_length: 2])
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

  test "json_schema" do
    type = type(:string)

    assert_equal type.json_schema(nil), {
      type: "string"
    }

    assert_equal type([:string, empty: false]).json_schema(nil), {
      type: "string",
      minLength: 1,
      description_topics: [
        "* Must not be empty"
      ]
    }

    assert_equal type([:string, downcase: true]).json_schema(nil), {
      type: "string",
      description_topics: [
        "* Case insensitive"
      ]
    }
  end
end
