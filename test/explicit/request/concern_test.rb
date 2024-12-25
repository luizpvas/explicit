# frozen_string_literal: true

require "test_helper"

class Explicit::Request::ConcernTest < ActiveSupport::TestCase
  module AuthenticatedRequest
    extend ActiveSupport::Concern

    included do
      header "Authorization", :string

      response 403, { error: "unauthorized" }
    end
  end

  class Request < Explicit::Request
    include AuthenticatedRequest

    response 200, {}
  end

  test "request concern" do
    responses = Request.send(:responses)

    assert_equal 3, responses.length
  end
end
