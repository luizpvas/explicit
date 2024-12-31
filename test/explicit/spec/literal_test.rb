# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::LiteralTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "foo", validate("foo", [:literal, "foo"])
    assert_ok 10, validate(10, [:literal, 10])
    assert_ok "bar", validate("bar", "bar")
  end

  test "error" do
    assert_error 'must be "foo"', validate("FOO", "foo")
    assert_error "must be 10", validate(15, [:literal, 10])
    assert_error 'must be "bar"', validate(" bar ", [:literal, "bar"])
  end
end
