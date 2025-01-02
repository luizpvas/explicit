# frozen_string_literal: true

require "test_helper"

class Explicit::Type::Modifiers::ParamLocationTest < ActiveSupport::TestCase
  test "type" do
    type = Explicit::Type.build([:_param_location, :path, :string])

    assert_equal :path, type.param_location
  end

  test "validation" do
    assert_ok "foo", validate("foo", [:_param_location, :path, :string])
    assert_error "must be a string", validate(nil, [:_param_location, :path, :string])
  end
end