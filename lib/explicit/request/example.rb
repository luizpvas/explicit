# frozen_string_literal: true

class Explicit::Request::Example
  def self.clear_saved_examples!
    File.open(Explicit.configuration.request_examples_file_path, "w") do |file|
      file.write("")
    end
  end

  attr_reader :route, :params, :headers, :response

  def initialize(route:, params:, headers:, response:)
    @route = route
    @params = params
    @headers = headers
    @response = response
  end

  def encode
    { route:, params:, headers:, response: }.to_json
  end

  def save!
    return

    File.write(
      Explicit.configuration.request_examples_file_path,
      self.encode,
      mode: "a+"
    )
  end
end
