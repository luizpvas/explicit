# frozen_string_literal: true

require "test_helper"

class Schema::Type::RecordTest < ActiveSupport::TestCase
  USER_SCHEMA = { name: :string, age: [:integer, parse: true] }

  test "ok" do
    assert_ok(
      { name: "Bilbo", age: 111 },
      validate({ name: "Bilbo", age: "111" }, USER_SCHEMA)
    )
  end

  test "error" do
    assert_error(
      { age: :integer },
      validate({ name: "Bilbo" }, USER_SCHEMA)
    )

    assert_error(
      { name: :string },
      validate({}, USER_SCHEMA)
    )
  end
end
