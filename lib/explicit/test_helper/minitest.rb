# frozen_string_literal: true

module Explicit::TestHelper::Minitest
  extend ActiveSupport::Concern

  # RSpec.configure do |config|
  #   config.after(:suite) do
  #     next if !Explicit.configuration.request_examples_persistance_enabled?

  #     Explicit::TestHelper::ExampleRecorder.instance.save!
  #   end
  # end

  included do
    ::Minitest.after_run do
      next if !Explicit.configuration.request_examples_persistance_enabled?

      Explicit::TestHelper::ExampleRecorder.instance.save!
    end
  end
end