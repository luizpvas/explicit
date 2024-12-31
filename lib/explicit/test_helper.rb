# frozen_string_literal: true

module Explicit::TestHelper
  extend ActiveSupport::Concern

  if Explicit.configuration.request_examples_persistance_enabled?
    if Explicit.configuration.test_runner == :rspec
      ::RSpec.configure do |config|
        config.after(:suite) do
          Explicit::TestHelper::ExampleRecorder.instance.save!
        end
      end
    else
      ::Minitest.after_run do
        Explicit::TestHelper::ExampleRecorder.instance.save!
      end
    end
  end

  included do
    if Explicit.configuration.test_runner == :minitest
      # TODO: improve this logic
      running_in_parallel = Minitest.parallel_executor.is_a?(ActiveSupport::Testing::ParallelizeExecutor)

      if running_in_parallel
        uri = Explicit::TestHelper::ExampleRecorder.start_service

        parallelize_setup do
          Explicit::TestHelper::ExampleRecorder.set_remote_instance(uri)
        end
      end
    end
  end

  def fetch(request, params: {}, headers: {}, **opts)
    route = request.send(:routes).first

    if route.nil?
      raise <<-DESC
      The request #{request} must define at least one route. For example:

        get "/customers/:customer_id"
        post "/article/:article_id/comments"
        put "/user/preferences"

      Important: adding a route to the request does not substitute the entry
      on `routes.rb`.
      DESC
    end

    method = route.method
    path = (request.get_base_path || "") + route.path

    process(method, path, params:, headers:)

    response = Explicit::Request::Response.new(
      status: @response.status,
      data: @response.parsed_body.deep_symbolize_keys
    )

    ensure_response_matches_spec!(request, response)

    if opts[:save_as_example]
      ExampleRecorder.instance.add(
        request_gid: request.gid,
        params:,
        headers:,
        response:
      )
    end

    response
  end

  def ensure_response_matches_spec!(request, response)
    responses_spec = request.send(:responses_spec, status: response.status)

    case responses_spec.validate(response.data.with_indifferent_access)
    in [:ok, _] then :all_good
    in [:error, err] then raise Explicit::Request::InvalidResponseError.new(response, err)
    end
  end
end
