# frozen_string_literal: true

require "test_helper"

class Explicit::Type::AnyTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok true, validate(true, :any)
    assert_ok "true", validate("true", :any)
    assert_ok 1, validate(1, :any)
    assert_ok nil, validate(nil, :any)
    assert_ok [ 1, 2, 3 ], validate([ 1, 2, 3 ], :any)
  end

  test "swagger_schema" do
    type = type([ :description, "hello", :any ])

    assert_equal type.swagger_schema, {
      description: "hello"
    }
  end

  test "json_schema" do
    type = type([ :description, "hello", :any ])

    assert_equal type.json_schema, {
      type: "string",
      description: "hello"
    }
  end
end
