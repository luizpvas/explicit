# frozen_string_literal: true

require "test_helper"

class Explicit::Type::ArrayTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok [], validate([], [:array, :string])
    assert_ok [""], validate([""], [:array, :string])
    assert_ok ["foo", "bar"], validate(["foo", "bar"], [:array, :string])
  end

  test "empty" do
    assert_ok ["foo"], validate(["foo"], [:array, :string, empty: false])

    assert_error :empty, validate([], [:array, :string, empty: false])
  end

  test "error" do
    assert_error "invalid item at index(1): must be a string", validate(["foo", 10], [:array, :string])
    assert_error "invalid item at index(2): must be a string", validate(["foo", "bar", nil], [:array, :string])
    assert_error "invalid item at index(0): must be a string", validate([10], [:array, :string])
    assert_error "invalid item at index(0): must be a string", validate([nil], [:array, :string])
    assert_error "invalid item at index(0): must be a string", validate([["foo"]], [:array, :string])
  end

  test "swagger" do
    assert_equal type([:array, :string, empty: false]).swagger_schema, {
      type: "array",
      items: {
        type: "string"
      },
      minItems: 1
    }
  end
end
