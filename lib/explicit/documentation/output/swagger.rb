# frozen_string_literal: true

module Explicit::Documentation::Output
  class Swagger
    InconsistentBasePathsError = Class.new(RuntimeError)
    InconsistentBaseURLsError = Class.new(RuntimeError)

    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    # top level attributes:
    # swagger: 2.0
    # info
    # host
    # basePath
    # tags
    # schemes
    # paths
    # securityDefinitions
    # definitions
    # externalDocs

    def to_json
      {
        swagger: "2.0",
        info: {
          title: builder.get_page_title,
        },
        host: get_host_from_base_url,
        schemes: get_schemes_from_base_url,
        basePath: get_base_path,
        tags: build_tags_from_sections,
        paths: build_paths_from_requests
      }
    end

    def call
      raise NotImplementedError
    end

    private
      def get_host_from_base_url
        base_urls = builder.requests.map(&:get_base_url).uniq

        if !base_urls.one?
          raise InconsistentBaseURLsError.new <<~TXT
            There are requests with different base URLs in the same documentation,
            which is not supported by Swagger.

            There are requests with the following base URLs:

              #{base_urls.join("\n  ")}

            Please make sure all requests have the same base URL.
          TXT
        end

        URI(base_urls.first).authority
      end

      def get_schemes_from_base_url
        url = builder.requests.first.get_base_url

        [URI(url).scheme]
      end

      def get_base_path
        base_paths = builder.requests.map(&:get_base_path).uniq

        if !base_paths.one?
          raise InconsistentBasePathsError.new <<~TXT
            There are requests with different base paths in the same documentation,
            which is not supported by Swagger.

            There are requests with the following base paths:

              #{base_paths.join("\n  ")}

            Please make sure all requests have the same base path.
          TXT
        end

        base_paths.first
      end

      def build_tags_from_sections
        builder.sections.filter(&:contains_request?).map do |section|
          { name: section.name }
        end
      end

      def build_paths_from_requests
        paths = {}

        builder.sections.filter(&:contains_request?).each do |section|
          section.pages.filter(&:request?).each do |page|
            request = page.request
            route = request.routes.first

            paths[route.path_with_curly_syntax] = {
              route.method.to_s.downcase => {
                tags: [section.name],
                summary: request.get_title,
                description: request.get_description
              }
            }
          end
        end

        paths
      end
  end
end
