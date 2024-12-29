# frozen_string_literal: true

class Explicit::Request::InvalidResponseError < ::RuntimeError
  def initialize(response, error)
    error => [:one_of, *errs]
    error = errs.map { format_response_spec(response, _1) }.join("\n")


    super <<-TXT


Got:

HTTP #{response.status} #{JSON.pretty_generate(response.data)}

This response doesn't match any spec. Here are the errors:

#{error.presence || " ==> no response specs found for status #{response.status}"}

    TXT
  end

  private
    def format_response_spec(response, error)
      error = Explicit::Spec::Error.translate(error)

      <<-TXT
HTTP #{response.status} #{JSON.pretty_generate(error)}
      TXT
    end
end