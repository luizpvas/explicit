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
        paths: build_paths_from_requests
      }
    end

    def call(request)
      @swagger_document ||= swagger_document

      [200, {"Content-Type" => "application/json"}, [@swagger_document.to_json]]
    end

    private
      def get_base_url
        base_urls = builder.requests.map(&:get_base_url).uniq
        base_paths = builder.requests.map(&:get_base_path).uniq

        if !base_urls.one?
          raise InconsistentBaseURLError.new <<~TXT
            There are requests with different base URLs in the same documentation,
            which is not supported by Swagger.

            The following base URLs are present:

              #{base_urls.join("\n  ")}

            Please make sure all requests have the same base URL.
          TXT
        end

        if !base_paths.one?
          raise InconsistentBasePathError.new <<~TXT
            There are requests with different base paths in the same documentation,
            which is not supported by Swagger.

            The following base paths are present:

              #{base_paths.join("\n  ")}

            Please make sure all requests have the same base path.
          TXT
        end

        base_urls.first + base_paths.first
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

            paths[route.path_with_curly_syntax][route.method.to_s] = {
              tags: [section.name],
              summary: request.get_title,
              description: request.get_description,
              parameters: build_parameters(request),
              requestBody: build_request_body(request),
              responses: build_responses(request)
            }.compact_blank
          end
        end

        paths
      end

      def build_parameters(request)
        path_params_type = request.params_type.path_params_type

        path_params_type.attributes.map do |name, type|
          {
            name: name.to_s,
            in: "path",
            required: type.required?,
            schema: type.swagger_schema,
            style: "simple"
          }
        end
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
            .map.with_index { |example, index| [index, { value: example }] }
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
            [index.to_s, { value: example.response.data }]
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
