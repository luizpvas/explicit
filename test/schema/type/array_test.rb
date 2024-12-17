# frozen_string_literal: true

require "test_helper"

class Schema::Type::ArrayTest < ActiveSupport::TestCase
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
    assert_error [:array, :string], validate(["foo", 10], [:array, :string])
    assert_error [:array, :string], validate(["foo", "bar", nil], [:array, :string])
    assert_error [:array, :string], validate([10], [:array, :string])
    assert_error [:array, :string], validate([nil], [:array, :string])
    assert_error [:array, :string], validate([["foo"]], [:array, :string])
  end
end
