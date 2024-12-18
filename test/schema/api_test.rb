# frozen_string_literal: true

require "test_helper"

class Schema::APITest < ActiveSupport::TestCase
  class Schema < Schema::API
    post "/articles"

    description "Article creation"

    header :Authorization, :string

    param :name, [:string, empty: false]
    param :published_at, :date_time_iso8601

    response 200, { article: { id: :integer } }
  end

  test ""
end
