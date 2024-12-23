# frozen_string_literal: true

require "test_helper"

class Schema::Type::OneOfTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "foo", validate("foo",  [:one_of, :string, :integer])
    assert_ok 10, validate(10, [:one_of, :string, :integer])
  end

  test "error" do
    assert_error [:one_of, :string, :integer], validate(true, [:one_of, :string, :integer])
    assert_error [:one_of, :empty, :integer], validate("", [:one_of, [:string, empty: false], :integer])
  end
end
