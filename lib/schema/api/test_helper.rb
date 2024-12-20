# frozen_string_literal: true

module Schema::API::TestHelper
  Response = ::Data.define(:status, :data)

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

    Response.new(
      status: @response.status,
      data: @response.parsed_body.with_indifferent_access
    )
  end
end
