# frozen_string_literal: true

require "test_helper"

class Explicit::Type::RecordTest < ActiveSupport::TestCase
  USER_SCHEMA = { name: :string, age: :integer }

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
      { company: { name: "must be a string" } },
      validate({ name: "John", company: {} }, customer_schema)
    )

    assert_error(
      { company: "must be an object" },
      validate({ name: "John" }, customer_schema)
    )
  end

  test "error" do
    assert_error "must be an object", validate(nil, USER_SCHEMA)
    assert_error "must be an object", validate("", USER_SCHEMA)
    assert_error "must be an object", validate([], USER_SCHEMA)

    assert_error(
      { age: "must be an integer" },
      validate({ name: "Bilbo" }, USER_SCHEMA)
    )

    assert_error(
      { name: "must be a string", age: "must be an integer" },
      validate({}, USER_SCHEMA)
    )
  end

  test "swagger" do
    type = type([
      :description,
      "desc",
      [:default, { name: "foo" }, { name: :string }]
    ])

    assert_equal type.swagger_schema, {
      type: "object",
      properties: {
        name: {
          type: "string"
        }
      },
      required: %w[name],
      default: { name: "foo" },
      description: "desc"
    }
  end

  test "json_schema" do
    type = type([
      :description,
      "desc",
      {
        name: :string,
        email: :string
      }
    ])

    assert_equal type.json_schema, {
      type: "object",
      description: "desc",
      properties: {
        name: { type: "string" },
        email: { type: "string" }
      },
      required: %w[name email],
      additionalProperties: false
    }
  end
end
