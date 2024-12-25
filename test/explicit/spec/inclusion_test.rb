# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::InclusionTest < ActiveSupport::TestCase
  RGB = %w[red green blue]

  test "ok" do
    assert_ok "red", validate("red", [:inclusion, RGB])
    assert_ok "green", validate("green", [:inclusion, RGB])
    assert_ok "blue", validate("blue", [:inclusion, RGB])
  end

  test "error" do
    assert_error [:inclusion, RGB], validate(nil, [:inclusion, RGB])
    assert_error [:inclusion, RGB], validate(" red", [:inclusion, RGB])
    assert_error [:inclusion, RGB], validate("RED", [:inclusion, RGB])
    assert_error [:inclusion, RGB], validate(["red"], [:inclusion, RGB])
  end
end
