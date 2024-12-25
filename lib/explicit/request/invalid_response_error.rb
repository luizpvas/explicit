# frozen_string_literal: true

class Explicit::Request::InvalidResponseError < ::RuntimeError
  def initialize(response, error)
    super <<-TXT
      Response did not match expected spec.

      Got:

      #{response.inspect}

      Expected:

      #{error.inspect}
    TXT
  end
end