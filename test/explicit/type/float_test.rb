# frozen_string_literal: true

require "test_helper"

class Explicit::Type::FloatTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok 10, validate(10, :float)
    assert_ok 0.001, validate(0.001, :float)
    assert_ok (-1), validate(-1, :float)
    assert_ok 1.5, validate("1.5", :float)
    assert_ok (-1.1), validate("-1.1", :float)
  end

  test "min max" do
    assert_ok 1, validate(1, [ :float, min: 1, max: 2 ])
    assert_ok 2, validate(2, [ :float, min: 1, max: 2 ])

    assert_error "must be at least 1", validate(0, [ :float, min: 1, max: 2 ])
    assert_error "must be at most 2", validate(3, [ :float, min: 1, max: 2 ])
  end

  test "negative" do
    assert_ok (-1), validate(-1, [ :float, negative: true ])
    assert_ok 1, validate(1, [ :float, negative: false ])

    assert_error "must not be negative", validate(-1, [ :float, negative: false ])
    assert_error "must be negative", validate(1, [ :float, negative: true ])
  end

  test "positive" do
    assert_ok 1, validate(1, [ :float, positive: true ])
    assert_ok -1, validate(-1, [ :float, positive: false ])

    assert_error "must not be positive", validate(1, [ :float, positive: false ])
    assert_error "must be positive", validate(0, [ :float, positive: true ])
  end

  test "error" do
    assert_error "must be a number", validate(nil, :float)
    assert_error "must be a number", validate("foo", :float)
    assert_error "must be a number", validate([], :float)
    assert_error "must be a number", validate({}, :float)
  end

  test "json_schema" do
    type = type([:float, min: 0, max: 10])

    assert_equal type.json_schema(nil), {
      type: "number",
      minimum: 0,
      maximum: 10
    }

    assert_equal type([ :float, positive: false ]).json_schema(nil), {
      type: "number",
      description_topics: [
        "* Must not be positive"
      ]
    }

    assert_equal type([ :float, positive: true ]).json_schema(nil), {
      type: "number",
      description_topics: [
        "* Must be positive"
      ]
    }

    assert_equal type([ :float, negative: false ]).json_schema(nil), {
      type: "number",
      description_topics: [
        "* Must not be negative"
      ]
    }

    assert_equal type([ :float, negative: true ]).json_schema(nil), {
      type: "number",
      description_topics: [
        "* Must be negative"
      ]
    }
  end
end
