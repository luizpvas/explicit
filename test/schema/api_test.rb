require "test_helper"

class Schema::ApiTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Schema::Api::VERSION
  end
end
