# frozen_string_literal: true

class API::V1::SessionsController
  DestroyRequest = API::V1::Authentication::AuthenticatedRequest.new do
    delete "/sessions"

    description <<~MD
    Revokes the authentication token used to authenticate the request, which
    prevents the token from being used in the future.
    MD

    response 200, { message: "session revoked" }
  end
end
