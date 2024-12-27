# frozen_string_literal: true

class Explicit::Configuration
  attr_accessor :request_examples_file_path

  def initialize
    @request_examples_file_path = ::Rails.root&.join("storage/explicit_request_examples.jsonl")
  end
end