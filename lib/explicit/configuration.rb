# frozen_string_literal: true

class Explicit::Configuration
  def request_examples_file_path=(path)
    @request_examples_file_path = path
  end

  def request_examples_file_path
    @request_examples_file_path ||= ::Rails.root&.join("storage/explicit_request_examples.json")
  end
end