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
    total_examples_count = @examples.sum { |_, examples| examples.size }

    puts ""
    puts ""
    puts "  [Explicit] ========="
    puts "  [Explicit] Saving request examples to #{Explicit.configuration.request_examples_file_path}"
    puts "  [Explicit] #{total_examples_count} requests recorded"
    puts "  [Explicit] ========="

    file_path = Explicit.configuration.request_examples_file_path

    ::File.write(file_path, @examples.to_json, mode: "w")
  end
end
