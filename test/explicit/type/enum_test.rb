# frozen_string_literal: true

require "test_helper"

class Explicit::Type::EnumTest < ActiveSupport::TestCase
  RGB = %w[red green blue]

  test "ok" do
    assert_ok "red", validate("red", [:enum, RGB])
    assert_ok "green", validate("green", [:enum, RGB])
    assert_ok "blue", validate("blue", [:enum, RGB])
  end

  test "error" do
    assert_error 'must be one of: ["red", "green", "blue"]', validate(nil, [:enum, RGB])
    assert_error 'must be one of: ["red", "green", "blue"]', validate(" red", [:enum, RGB])
    assert_error 'must be one of: ["red", "green", "blue"]', validate("RED", [:enum, RGB])
    assert_error 'must be one of: ["red", "green", "blue"]', validate(["red"], [:enum, RGB])
  end

  test "json_schema" do
    type = type([:enum, RGB])

    assert_equal type.json_schema(nil), {
      type: "string",
      enum: RGB
    }
  end
end
