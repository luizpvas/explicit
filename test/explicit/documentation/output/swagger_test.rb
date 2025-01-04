# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::Output::SwaggerTest < ActiveSupport::TestCase
  test "version" do
    assert_equal "3.0.1", swagger[:openapi]
  end

  test "info" do
    assert_equal "Acme API", swagger.dig(:info, :title)
    assert_equal "1.0.1", swagger.dig(:info, :version)
  end

  test "host" do
    assert_equal "localhost:3000", swagger[:host]
  end

  test "schemes" do
    assert_equal ["http"], swagger[:schemes]
  end

  test "basePath" do
    assert_equal "/api/v1", swagger[:basePath]
  end

  test "tags" do
    assert_equal "Auth", swagger.dig(:tags, 0, :name)
    assert_equal "Articles", swagger.dig(:tags, 1, :name)
    assert_equal "Others", swagger.dig(:tags, 2, :name)
  end

  test "registration request" do
    swagger.dig(:paths, "/registrations", "post").tap do |req|
      assert_equal ["Auth"], req.dig(:tags)
      assert_equal "Registration", req.dig(:summary)
      assert_match "Attempts to register a new user", req.dig(:description)
    end
  end

  private
    def swagger
      @swagger ||= API::V1::Documentation.documentation_builder.swagger.swagger_document
    end
end
