# frozen_string_literal: true

require "test_helper"

class Schema::Type::SchemaTest < ActiveSupport::TestCase
  USER_SPEC = { name: :string, age: [:integer, parse: true] }

  test "ok" do
    assert_ok(
      { name: "Bilbo", age: 111 },
      validate({ name: "Bilbo", age: "111" }, USER_SPEC)
    )
  end

  test "error" do
    assert_error(
      { age: :integer },
      validate({ name: "Bilbo" }, USER_SPEC)
    )

    assert_error(
      { name: :string },
      validate({}, USER_SPEC)
    )
  end
end
