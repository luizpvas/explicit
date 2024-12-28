# frozen_string_literal: true

class Explicit::Configuration
  def request_examples_file_path=(path)
    @request_examples_file_path = path
  end

  def request_examples_file_path
    @request_examples_file_path ||= ::Rails.root&.join("public/explicit_request_examples.json")
  end

  def request_examples_persistance_enabled?
    ENV["EXPLICIT_PERSIST_EXAMPLES"].in? %w[true 1 on]
  end
end