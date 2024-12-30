# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::EnumTest < ActiveSupport::TestCase
  RGB = %w[red green blue]

  test "ok" do
    assert_ok "red", validate("red", [:enum, RGB])
    assert_ok "green", validate("green", [:enum, RGB])
    assert_ok "blue", validate("blue", [:enum, RGB])
  end

  test "error" do
    assert_error [:enum, RGB], validate(nil, [:enum, RGB])
    assert_error [:enum, RGB], validate(" red", [:enum, RGB])
    assert_error [:enum, RGB], validate("RED", [:enum, RGB])
    assert_error [:enum, RGB], validate(["red"], [:enum, RGB])
  end
end
