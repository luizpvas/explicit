# frozen_string_literal: true

class API::V1::EverythingController < API::V1::BaseController
  Request = API::V1::Request.new do
    post "/everything"

    description <<~MD
      This endpoint uses all available features in the Explicit gem.
    MD

    param :string1, [:string, empty: false, strip: true, minlength: 1, maxlength: 100]

    param :integer1, [:integer, parse: true, min: 1, max: 100]

    param :hash1, [
      :hash,
      [:string, empty: false],
      [:description, "A description of the hash values", [:array, [:integer, min: 0, max: 10, parse: true]]]
    ]

    param :file1, [:file, maxsize: 2.megabytes, mime: %w[image/jpeg image/png]]

    response 200, { message: "ok" }
  end
  
  def create
    validated_data = Request.validate!(params)

    render json: { message: "ok" }
  end
end
