# frozen_string_literal: true

require "test_helper"

class Explicit::Type::Modifiers::AuthTypeTest < ::ActiveSupport::TestCase
  test "type" do
    type = ::Explicit::Type.build([:_auth_type, :bearer, :string])

    assert_equal :bearer, type.auth_type
  end

  test "validation" do
    assert_ok "foo", validate("foo", [:_auth_type, :bearer, :string])
    assert_error "must be a string", validate(nil, [:_auth_type, :bearer, :string])
  end
end
