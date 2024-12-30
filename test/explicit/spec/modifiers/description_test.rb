# frozen_string_literal: true

require "test_helper"

class Explicit::Spec::Modifiers::DescriptionTest < ActiveSupport::TestCase
  test "runs validation using subspec" do
    assert_ok "foo", validate("foo", [:description, "text here", :string])
    
    assert_error :integer, validate("foo", [:description, "text here", :integer])
  end
end