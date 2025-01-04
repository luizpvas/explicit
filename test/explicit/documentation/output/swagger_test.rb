# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::Output::SwaggerTest < ActiveSupport::TestCase
  test "version" do
    assert_equal "2.0", swagger.to_json[:swagger]
  end

  test "info" do
    assert_equal "Acme API", swagger.to_json.dig(:info, :title)
  end

  test "host" do
    assert_equal "localhost:3000", swagger.to_json[:host]
  end

  test "schemes" do
    assert_equal ["http"], swagger.to_json[:schemes]
  end

  test "basePath" do
    assert_equal "/api/v1", swagger.to_json[:basePath]
  end

  test "tags" do
    assert_equal "Auth", swagger.to_json.dig(:tags, 0, :name)
    assert_equal "Articles", swagger.to_json.dig(:tags, 1, :name)
    assert_equal "Others", swagger.to_json.dig(:tags, 2, :name)
  end

  private
    def swagger
      API::V1::Documentation.documentation_builder.swagger
    end
end
