# frozen_string_literal: true

require "test_helper"

class Schemax::Spec::AgreementTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :agreement)
  end

  test "parse" do
    assert_ok true, validate("true", [:agreement, parse: true])
    assert_ok true, validate("1", [:agreement, parse: true])
    assert_ok true, validate("on", [:agreement, parse: true])
  end

  test "error" do
    assert_error :agreement, validate(false, :agreement)
    assert_error :agreement, validate("false", :agreement)
    assert_error :agreement, validate("0", :agreement)
    assert_error :agreement, validate("off", :agreement)
    assert_error :agreement, validate(nil, :agreement)
    assert_error :agreement, validate(10, :agreement)
    assert_error :agreement, validate("foo", :agreement)
    assert_error :agreement, validate([], :agreement)
  end
end
