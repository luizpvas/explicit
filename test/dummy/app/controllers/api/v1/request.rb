# frozen_string_literal: true

module API::V1
  Request = Explicit::Request.new do
    base_url "http://localhost:3000"
    base_path "/api/v1"
  end
end