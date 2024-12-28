# frozen_string_literal: true

module Explicit::TestHelper::Minitest
  extend ActiveSupport::Concern

  included do
    Minitest.after_run do
      next if !Explicit.configuration.request_examples_persistance_enabled?

      Explicit::TestHelper::ExampleRecorder.instance.save!
    end
  end
  
  def request_via_test_provider(route:, params:, headers:)
    process(route.method, route.path, params:, headers:)

    Explicit::Request::Response.new(
      status: @response.status,
      data: @response.parsed_body.deep_symbolize_keys
    )
  end
end