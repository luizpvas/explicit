# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::AgreementTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :agreement)
  end

  test "parse" do
    assert_ok true, validate("true", [:agreement, parse: true])
    assert_ok true, validate("1", [:agreement, parse: true])
    assert_ok true, validate(1, [:agreement, parse: true])
    assert_ok true, validate("on", [:agreement, parse: true])
  end

  test "error" do
    assert_error "must be accepted", validate(false, :agreement)
    assert_error "must be accepted", validate("false", :agreement)
    assert_error "must be accepted", validate("0", :agreement)
    assert_error "must be accepted", validate("off", :agreement)
    assert_error "must be accepted", validate(nil, :agreement)
    assert_error "must be accepted", validate(10, :agreement)
    assert_error "must be accepted", validate("foo", :agreement)
    assert_error "must be accepted", validate([], :agreement)
  end
end
