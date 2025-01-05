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
    assert_equal "http://localhost:3000/api/v1", swagger.dig(:servers, 0, :url)
  end

  test "tags" do
    assert_equal "Auth", swagger.dig(:tags, 0, :name)
    assert_equal "Articles", swagger.dig(:tags, 1, :name)
    assert_equal "Others", swagger.dig(:tags, 2, :name)
  end

  test "POST /registrations" do
    swagger.dig(:paths, "/registrations", "post").tap do |req|
      assert_equal ["Auth"], req.dig(:tags)
      assert_equal "Registration", req.dig(:summary)
      assert_match "Attempts to register a new user", req.dig(:description)
      assert_nil req.dig(:parameters)

      body_schema = req.dig(:requestBody, :content, "application/json", :schema)
      assert_equal "object", body_schema[:type]
      assert_equal ["name", "email_address", "password", "terms_of_use"], body_schema[:required]
    end
  end

  test "GET /articles/:article_id" do
    swagger.dig(:paths, "/articles/{article_id}", "get").tap do |req|
      assert_equal ["Articles"], req.dig(:tags)
      assert_equal "Get article", req.dig(:summary)
      
      assert_equal req.dig(:parameters, 0), {
        name: "Authorization",
        in: "header",
        required: true,
        schema: {
          type: "string"
        },
        style: "simple"
      }

      assert_equal req.dig(:parameters, 1), {
        name: "article_id",
        in: "path",
        required: true,
        schema: {
          type: "integer"
        },
        style: "simple"
      }

      assert_nil req.dig(:requestBody)
    end
  end

  private
    def swagger
      @swagger ||= API::V1::Documentation.documentation_builder.swagger.swagger_document
    end
end
