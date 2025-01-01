# frozen_string_literal: true

require "test_helper"

class Explicit::Type::Modifiers::DescriptionTest < ActiveSupport::TestCase
  test "runs validation using subtype" do
    assert_ok "foo", validate("foo", [:description, "text here", :string])
    
    assert_error "must be an integer", validate("foo", [:description, "text here", :integer])
  end
end