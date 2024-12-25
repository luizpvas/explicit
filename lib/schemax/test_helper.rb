# frozen_string_literal: true

module Schemax::TestHelper
  Response = ::Data.define(:status, :data) do
    def dig(...) = data.dig(...)
  end

  def fetch(request, params:, headers: nil)
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

    process(route.method, route.path, params:, headers:)

    response = Response.new(
      status: @response.status,
      data: @response.parsed_body.deep_symbolize_keys
    )

    ensure_response_matches_spec!(request, response)

    response
  end

  def ensure_response_matches_spec!(request, response)
    allowed_responses = request.send(:responses)
    response_validator = Schemax::Spec.build([:one_of, *allowed_responses])

    case response_validator.call({ status: response.status, data: response.data.with_indifferent_access })
    in [:ok, _] then :all_good
    in [:error, err] then raise Schemax::Request::InvalidResponseError.new(response, err)
    end
  end
end
