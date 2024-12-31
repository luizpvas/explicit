# frozen_string_literal: true

module API::V1
  Request = Explicit::Request.new do
    base_url "https://example-app.com"
    base_path "/api/v1"
  end
end