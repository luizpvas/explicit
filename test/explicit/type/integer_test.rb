# frozen_string_literal: true

require "test_helper"

class Explicit::Type::IntegerTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok 10, validate(10, :integer)
    assert_ok -1, validate(-1, :integer)
    assert_ok 1, validate("1", :integer)
    assert_ok -1, validate("-1", :integer)
  end

  test "min max" do
    assert_ok 1, validate(1, [ :integer, min: 1, max: 2 ])
    assert_ok 2, validate(2, [ :integer, min: 1, max: 2 ])

    assert_error "must be at least 1", validate(0, [ :integer, min: 1, max: 2 ])
    assert_error "must be at most 2", validate(3, [ :integer, min: 1, max: 2 ])
  end

  test "negative" do
    assert_ok 1, validate(1, [ :integer, negative: false ])
    assert_ok (-1), validate(-1, [ :integer, negative: true ])

    assert_error "must not be negative", validate(-1, [ :integer, negative: false ])
    assert_error "must be negative", validate(0, [ :integer, negative: true ])
  end

  test "positive" do
    assert_ok 1, validate(1, [ :integer, positive: true ])
    assert_ok (-1), validate(-1, [ :integer, positive: false ])

    assert_error "must not be positive", validate(1, [ :integer, positive: false ])
    assert_error "must be positive", validate(-1, [ :integer, positive: true ])
  end

  test "error" do
    assert_error "must be an integer", validate(nil, :integer)
    assert_error "must be an integer", validate("foo", :integer)
    assert_error "must be an integer", validate([], :integer)
    assert_error "must be an integer", validate({}, :integer)
    assert_error "must be an integer", validate(9.5, :integer)
  end

  test "json_schema" do
    type = type([:integer, min: 0, max: 10])

    assert_equal type.json_schema(nil), {
      type: "integer",
      minimum: 0,
      maximum: 10
    }

    assert_equal type([ :integer, positive: false ]).json_schema(nil), {
      type: "integer",
      description_topics: [
        "* Must not be positive"
      ]
    }

    assert_equal type([ :integer, positive: true ]).json_schema(nil), {
      type: "integer",
      description_topics: [
        "* Must be positive"
      ]
    }

    assert_equal type([ :integer, negative: false ]).json_schema(nil), {
      type: "integer",
      description_topics: [
        "* Must not be negative"
      ]
    }

    assert_equal type([ :integer, negative: true ]).json_schema(nil), {
      type: "integer",
      description_topics: [
        "* Must be negative"
      ]
    }
  end
end
