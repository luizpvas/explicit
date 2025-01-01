# frozen_string_literal: true

class Explicit::Request::InvalidResponseError < ::RuntimeError
  def initialize(response, error)
    super <<-TXT


Got:

HTTP #{response.status} #{JSON.pretty_generate(response.data)}

This response doesn't match any type. Here are the errors:

#{error.presence || " ==> no response types found for status #{response.status}"}

    TXT
  end
end