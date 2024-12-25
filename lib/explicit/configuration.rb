# frozen_string_literal: true

class Explicit::Configuration
  attr_accessor :request_examples_path

  def initialize
    @request_examples_path = ::Rails.root&.join("storage/explicit_request_examples.json")
  end
end