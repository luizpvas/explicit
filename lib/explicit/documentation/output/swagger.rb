# frozen_string_literal: true

module Explicit::Documentation::Output
  class Swagger
    InconsistentBasePathError = Class.new(RuntimeError)
    InconsistentBaseURLError = Class.new(RuntimeError)

    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    def swagger_document
      paths = build_paths_from_requests

      securitySchemes = {}.tap do |hash|
        requests = paths.flat_map { |path, methods| methods.values }

        if requests.filter { _1.dig(:security, 0, :basicAuth) }.any?
          hash[:basicAuth] = { type: "http", scheme: "basic" }
        end

        if requests.filter { _1.dig(:security, 0, :bearerAuth) }.any?
          hash[:bearerAuth] = { type: "http", scheme: "bearer" }
        end
      end

      {
        openapi: "3.0.1",
        info: {
          title: builder.get_page_title,
          version: builder.get_version
        },
        servers: [
          {
            url: get_base_url
          }
        ],
        tags: build_tags_from_sections,
        paths: build_paths_from_requests,
        components: { securitySchemes: }
      }
    end

    def call(env)
      return respond_cors_preflight_request if env["REQUEST_METHOD"] == "OPTIONS"

      @swagger_document ||= swagger_document

      headers = cors_access_control_headers.merge({
        "Content-Type" => "application/json"
      })

      [ 200, headers, [ @swagger_document.to_json ] ]
    end

    def inspect
      "#{self.class.name}#call"
    end

    private
      def respond_cors_preflight_request
        [ 200, cors_access_control_headers, [] ]
      end

      def cors_access_control_headers
        return {} if !::Explicit.configuration.cors_enabled?

        {
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Methods" => "GET, OPTIONS",
          "Access-Control-Allow-Headers" => "Content-Type", 
          "Access-Control-Max-Age" => "86400"
        }
      end

      def get_base_url
        base_urls = builder.requests.map(&:get_base_url).uniq
        base_paths = builder.requests.map(&:get_base_path).uniq

        if !base_urls.compact_blank.empty? && !base_urls.one?
          raise InconsistentBaseURLError.new <<~TXT
            There are requests with different base URLs in the same documentation,
            which is not supported by Swagger.

            The following base URLs are present:

              #{base_urls.join("\n  ")}

            Please make sure all requests have the same base URL.
          TXT
        end

        if !base_paths.compact_blank.empty? && !base_paths.one?
          raise InconsistentBasePathError.new <<~TXT
            There are requests with different base paths in the same documentation,
            which is not supported by Swagger.

            The following base paths are present:

              #{base_paths.join("\n  ")}

            Please make sure all requests have the same base path.
          TXT
        end

        (base_urls.first || "") + (base_paths.first || "")
      end

      def build_tags_from_sections
        builder.sections.filter(&:contains_request?).map do |section|
          { name: section.name }
        end
      end

      def build_paths_from_requests
        paths = Hash.new { |hash, key| hash[key] = {} }

        builder.sections.filter(&:contains_request?).each do |section|
          section.pages.filter(&:request?).each do |page|
            request = page.request
            route = request.routes.first

            security =
              if request.requires_basic_authorization?
                [ { basicAuth: [] } ]
              elsif request.requires_bearer_authorization?
                [ { bearerAuth: [] } ]
              else
                nil
              end

            paths[route.path_with_curly_syntax][route.method.to_s] = {
              tags: [ section.name ],
              summary: request.get_title,
              description: request.get_description,
              parameters: build_parameters(request),
              requestBody: build_request_body(request),
              responses: build_responses(request),
              security:
            }.compact_blank
          end
        end

        paths
      end

      def build_parameters(request)
        headers =
          request.headers_type.attributes.filter_map do |name, type|
            # NOTE: skip Authorization header because swagger prefers the `security` directive for basic and bearer
            # authorization schemas. If not basic or bearer, then we add the Authorization header.
            next if name == "Authorization" && !request.custom_authorization_format?

            {
              name: name.to_s,
              in: "header",
              required: type.required?,
              schema: type.swagger_schema,
              style: "form"
            }
          end

        path_params =
          request.params_type.path_params_type.attributes.map do |name, type|
            {
              name: name.to_s,
              in: "path",
              required: type.required?,
              schema: type.swagger_schema,
              style: "form"
            }
          end

        query_params =
          request.params_type.query_params_type.attributes.map do |name, type|
            {
              name: name.to_s,
              in: "query",
              required: type.required?,
              schema: type.swagger_schema,
              style: "form"
            }
          end

        headers + path_params + query_params
      end

      def build_request_body(request)
        body_params_type = request.params_type.body_params_type
        content_type = request.accepts_file_upload? ? "multipart/form-data" : "application/json"

        return nil if body_params_type.attributes.empty?

        examples =
          request.examples
            .flat_map { |_, examples| examples }
            .filter_map do |example|
              case body_params_type.validate(example.params)
              in [:ok, validated_data] then validated_data
              in [:error, _] then nil
              end
            end
            .map.with_index { |example, index| [ index, { value: example } ] }
            .to_h

        {
          content: {
            content_type => {
              schema: body_params_type.swagger_schema,
              examples:
            }.compact_blank
          },
          required: body_params_type.attributes.any?
        }
      end

      def build_responses(request)
        responses = {}

        request.responses.each do |status, _|
          examples = request.examples[status].map.with_index do |example, index|
            [ index.to_s, { value: example.response.data } ]
          end.to_h

          responses[status] = {
            content: {
              "application/json" => {
                schema: request.responses_type(status:).swagger_schema,
                examples: examples
              }.compact_blank
            },
            description: Rack::Utils::HTTP_STATUS_CODES[status]
          }
        end

        responses
      end
  end
end
