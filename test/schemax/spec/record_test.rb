# frozen_string_literal: true

require "test_helper"

class Schemax::Spec::RecordTest < ActiveSupport::TestCase
  USER_SCHEMA = { name: :string, age: [:integer, parse: true] }

  test "ok" do
    assert_ok(
      { name: "Bilbo", age: 111 },
      validate({ name: "Bilbo", age: "111" }, USER_SCHEMA)
    )
  end

  test "nested records" do
    customer_schema = {
      name: :string,
      company: { name: :string }
    }

    assert_ok(
      { name: "John", company: { name: "Acme Co." } },
      validate({ name: "John", company: { name: "Acme Co." } }, customer_schema)
    )

    assert_error(
      { company: { name: :string } },
      validate({ name: "John", company: {} }, customer_schema)
    )
  end

  test "error" do
    assert_error(
      { age: :integer },
      validate({ name: "Bilbo" }, USER_SCHEMA)
    )

    assert_error(
      { name: :string, age: :integer },
      validate({}, USER_SCHEMA)
    )
  end
end
