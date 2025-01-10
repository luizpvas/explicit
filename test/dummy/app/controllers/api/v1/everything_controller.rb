# frozen_string_literal: true

class API::V1::EverythingController < API::V1::BaseController
  Request = API::V1::Request.new do
    post "/everything"

    title "Everything"

    description <<~MD
      This request uses all available types in the Explicit gem to showcase and
      test them.
    MD

    param :file1, [:file, max_size: 2.megabytes, content_types: %w[image/jpeg image/png]]

    param :string1, [:string, empty: false, strip: true, min_length: 1, max_length: 100], default: "Foo"

    param :integer1, [:integer, min: 1, max: 100], default: 5

    param :hash1, [
      :hash,
      [:string, empty: false],
      [:description, "A description of the hash values", [:array, [:integer, min: 0, max: 10]]]
    ]

    param :agreement1, :agreement

    param :big_decimal1, [:big_decimal, min: 0, max: 100]

    param :boolean1, :boolean

    param :date_time_iso8601, :date_time_iso8601

    param :date_time_posix, :date_time_posix

    param :enum1, [:enum, %w[one two three]]

    response 200, { message: "ok" }
  end
  
  def create
    validated_data = Request.validate!(params)

    render json: { message: "ok" }
  end
end
