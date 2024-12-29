# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::OneOfTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "foo", validate("foo",  [:one_of, :string, :integer])
    assert_ok 10, validate(10, [:one_of, :string, :integer])
  end

  test "error when variants are records" do
    contact_spec = [:one_of, { phone: :string }, { email: :string }]

    assert_error(
      { phone: :string },
      validate({ phone: nil }, contact_spec)
    )

    assert_error(
      { email: :string },
      validate({ email: true }, contact_spec)
    )

    assert_error [:one_of, :hash, :hash], validate(nil, contact_spec)
  end

  test "error" do
    assert_error [:one_of, :string, :integer], validate(true, [:one_of, :string, :integer])
    assert_error [:one_of, :empty, :integer], validate("", [:one_of, [:string, empty: false], :integer])
  end
end
