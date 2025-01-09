# frozen_string_literal: true

require "test_helper"

class Explicit::Type::OneOfTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "foo", validate("foo",  [:one_of, :string, :integer])
    assert_ok 10, validate(10, [:one_of, :string, :integer])
  end

  test "error" do
    assert_error "must be a string OR must be an integer", validate(true, [:one_of, :string, :integer])
    assert_error "must not be empty OR must be an integer", validate("", [:one_of, [:string, empty: false], :integer])
  end

  test "subtype error guesssing" do
    contact_info = [:one_of, { phone: :string }, { email: :string }]

    assert_error(
      { phone: "must be a string" },
      validate({ phone: nil }, contact_info)
    )

    assert_error(
      { email: "must be a string" },
      validate({ email: nil }, contact_info)
    )

    assert_error(
      <<~TXT.strip,
        {
          "phone": "must be a string"
        }

        OR

        {
          "email": "must be a string"
        }
      TXT
      validate({}, contact_info)
    )
  end
end
