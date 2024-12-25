# frozen_string_literal: true

class API::V1::SessionsController
  class DestroyRequest < Explicit::Request
    include API::V1::Authentication::Request

    delete "/api/v1/sessions"

    description <<-MD
    Revokes the authentication token used to authenticate the request, which
    prevents the token from being used in the future.
    MD

    response 200, { message: "session revoked" }
  end
end
