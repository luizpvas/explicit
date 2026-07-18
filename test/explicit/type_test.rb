# frozen_string_literal: true

require "test_helper"

class Explicit::TypeTest < ::ActiveSupport::TestCase
  test "raises an error when type spec is not supported" do
    assert_raises(Explicit::Type::InvalidTypeError) do
      type(:invalid_type)
    end
  end
end

