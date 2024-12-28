# frozen_string_literal: true

class Explicit::TestHelper::ExampleRecorder
  class << self
    def start_service
      ::DRb.start_service("drbunix:", instance).uri
    end

    def set_remote_instance(uri)
      ::DRb.stop_service

      @remote_instance = ::DRbObject.new_with_uri(uri)
    end

    def instance
      return @remote_instance if defined?(@remote_instance)

      @local_instance ||= new
    end
  end

  def initialize
    @examples = Hash.new { |hash, key| hash[key] = [] }
  end

  def add(request_gid:, params:, headers:, response:)
    @examples[request_gid] << Explicit::Request::Example.new(
      params:,
      headers:,
      response:
    )
  end

  def save!
    total_examples_count = @examples.sum { |_, examples| examples.size }
    file_path = Explicit.configuration.request_examples_file_path

    puts "" if Explicit.configuration.test_runner == :rspec
    puts ""
    puts "  [Explicit] ========="
    puts "  [Explicit] Saving request examples to #{file_path}"
    puts "  [Explicit] #{total_examples_count} requests recorded"
    puts "  [Explicit] ========="
    puts "" if Explicit.configuration.test_runner == :minitest


    ::File.write(file_path, @examples.to_json, mode: "w")
  end
end
