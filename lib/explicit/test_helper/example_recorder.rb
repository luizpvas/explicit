# frozen_string_literal: true

class Explicit::TestHelper::ExampleRecorder
  class << self
    def add(...)
      instance.add(...)
    end

    def instance
      @instance ||= new
    end
  end

  def initialize
    @examples = Hash.new { |hash, key| hash[key] = [] }
  end

  def add(request:, params:, headers:, response:)
    @examples[request.gid] << Explicit::Request::Example.new(params:, headers:, response:)
  end

  def save!
    puts ""
    puts "  [Explicit] ========="
    puts "  [Explicit] Saving request examples to #{Explicit.configuration.request_examples_file_path}"
    puts "  [Explicit] #{@examples.size} requests recorded"
    puts "  [Explicit] ========="
    puts ""

    file_path = Explicit.configuration.request_examples_file_path

    ::File.write(file_path, @examples.to_json, mode: "w")
  end
end
