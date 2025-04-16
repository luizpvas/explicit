# frozen_string_literal: true

require "test_helper"

class Explicit::MCPServerTest < ::ActiveSupport::TestCase
  test "builds a rails engine when all requests are compatible with tool schema" do
    request = ::Explicit::Request.new do
      param :name, :string
    end
  end
end
