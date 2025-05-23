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

  test "json_schema" do
    type = type(:any)

    assert_equal type.json_schema(:swagger), {}
    assert_equal type.json_schema(:mcp), { type: "string" }
  end
end