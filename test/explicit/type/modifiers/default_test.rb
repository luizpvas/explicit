# frozen_string_literal: true

require "test_helper"

class Explicit::Type::Modifiers::TestDefault < ActiveSupport::TestCase
  test "default value" do
    assert_ok "foo", validate(nil, [:default, "foo", :string])
    assert_ok "", validate("", [:default, "foo", :string])
    assert_ok 1, validate(nil, [:default, 1, :integer])
    assert_ok 0, validate(0, [:default, 1, :integer])
  end

  test "default with lambda" do
    calls = 0
    defaultval = -> { calls += 1 }

    assert_ok 1, validate(nil, [:default, defaultval, :integer])
    assert_ok 2, validate(nil, [:default, defaultval, :integer])
    assert_ok 3, validate(nil, [:default, defaultval, :integer])
  end
end
