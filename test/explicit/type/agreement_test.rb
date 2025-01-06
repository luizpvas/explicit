# frozen_string_literal: true

require "test_helper"

class Explicit::Type::AgreementTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :agreement)
    assert_ok true, validate("true", :agreement)
    assert_ok true, validate("1", :agreement)
    assert_ok true, validate(1, :agreement)
    assert_ok true, validate("on", :agreement)
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

  test "swagger" do
    assert_equal type(:agreement).swagger_schema, {
      type: "boolean",
      description: "* must be true"
    }
  end
end
