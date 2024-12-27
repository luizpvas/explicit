# frozen_string_literal: true

class Explicit::Request::Example::Recorder
  def initialize
    @examples = Hash.new { |hash, key| hash[key] = [] }
  end

  def add(request:, params:, headers:, response:)
    @examples[request.gid] << Explicit::Request::Example.new(params:, headers:, response:)
  end

  def save!
    file_path = Explicit.configuration.request_examples_file_path

    ::File.write(file_path, @examples.to_json, mode: "w")
  end
end
