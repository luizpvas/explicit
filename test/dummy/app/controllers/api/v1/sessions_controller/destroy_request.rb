# frozen_string_literal: true

class API::V1::SessionsController
  class DestroyRequest < API::V1::Authentication::AuthenticatedRequest
    delete "/api/v1/sessions"

    description <<-MD
    Revokes the authentication token used to authenticate the request, which
    prevents the token from being used in the future.
    MD

    response 200, { message: "session revoked" }
  end
end
