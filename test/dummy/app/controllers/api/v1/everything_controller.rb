# frozen_string_literal: true

class API::V1::EverythingController < API::V1::BaseController
  CreateRequest = API::V1::Request.new do
    post "/everything"

    description <<~MD
      This endpoint uses all available features in the Explicit gem.
    MD

    param :string1, [:string, empty: false, strip: true, minlength: 1, maxlength: 100, format: /\A[a-z]+\z/]
    param :integer1, [:integer, parse: true, min: 1, max: 100]
    param :hash1, [
      :hash,
      [:string, empty: false],
      [:description, "A description of the hash values", [:array, :integer]]
    ]

    response 200, {
      string1: :string,
      integer1: :integer,
      hash1: [:hash, [:string, empty: false], [:array, :integer]]
    }
  end
  
  def create
    validated_data = CreateRequest.validate!(params)

    render json: validated_data
  end
end
