# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::NilableTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok nil, validate(nil, [:nilable, :string])
    assert_ok "foo", validate("foo", [:nilable, :string])
  end

  test "error" do
    assert_error :string, validate(10, [:nilable, :string])
    assert_error :string, validate(:foo, [:nilable, :string])
  end
end
