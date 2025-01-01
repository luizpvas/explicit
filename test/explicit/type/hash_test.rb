# frozen_string_literal: true

require "test_helper"

class Explicit::Type::HashTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      { "foo" => "yes", "bar" => "no" },
      validate({ "foo" => "yes", "bar" => "no" }, [:hash, :string, :string])
    )

    assert_ok(
      { 10 => true },
      validate({ "10" => "true" }, [:hash, [:integer, parse: true], [:boolean, parse: true]])
    )
  end

  test "empty" do
    assert_ok(
      { "foo" => "bar" },
      validate({ "foo" => "bar" }, [:hash, :string, :string, empty: false])
    )

    assert_error(
      "must not be empty",
      validate({}, [:hash, :string, :string, empty: false])
    )
  end

  test "error key" do
    assert_error(
      "invalid key (10): must be a string",
      validate({ 10 => "foo" }, [:hash, :string, :string])
    )
  end

  test "error value" do
    assert_error(
      "invalid value at key (foo): must be an integer",
      validate({ "foo" => "bar" }, [:hash, :string, :integer])
    )
  end
end
