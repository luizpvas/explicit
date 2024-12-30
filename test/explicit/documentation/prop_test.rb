# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::PropTest < ActiveSupport::TestCase
  Prop = Explicit::Documentation::Prop

  test "string" do
    assert_equal Prop.just_name("string"), Prop.from_spec(:string)
  end
end