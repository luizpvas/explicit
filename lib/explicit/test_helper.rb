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
      running_in_parallel = Minitest.parallel_executor.is_a?(
        ActiveSupport::Testing::ParallelizeExecutor
      )

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
    path = path.gsub(/:(\w+)/) { params.delete($1.to_sym).to_s }

    process(method, path, params:, headers:)

    if @response.headers["content-type"]&.include?("text/html")
      html = @response.parsed_body

      html.search("style").each { _1.remove }
      html.search("script").each { _1.remove }

      raise <<~TXT
        Unexpected HTML response:

        #{html.text}
      TXT
    end

    response = Explicit::Request::Response.new(
      status: @response.status,
      data: @response.parsed_body.deep_symbolize_keys
    )

    ensure_response_matches_documented_type!(request, response)

    if opts[:save_as_example]
      params = replace_uploaded_files_with_filenames(params)

      ExampleRecorder.instance.add(
        request_gid: request.gid,
        params:,
        headers:,
        response:
      )
    end

    response
  end

  def ensure_response_matches_documented_type!(request, response)
    responses_type = request.responses_type(status: response.status)

    case responses_type.validate(response.data.with_indifferent_access)
    in [:ok, _] then :all_good
    in [:error, err] then raise Explicit::Request::InvalidResponseError.new(response, err)
    end
  end

  def replace_uploaded_files_with_filenames(hash)
    hash.to_h do |key, value|
      if Explicit::Type::File::FILE_CLASSES.any? { value.is_a?(_1) }
        [key, "@#{value.original_filename}"]
      elsif value.is_a?(::Hash)
        [key, replace_uploaded_files_with_filenames(value)]
      else
        [key, value]
      end
    end
  end
end
