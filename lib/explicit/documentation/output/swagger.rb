# frozen_string_literal: true

module Explicit::Documentation::Output
  class Swagger
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
        basePath: get_base_path,
        tags: build_tags_from_sections,
        schemes: get_schemes_from_base_url
      }
    end

    def call
      raise NotImplementedError
    end

    private
      def get_host_from_base_url
        url = builder.requests.first.get_base_url

        # TODO: raise error if not set or inconsistent

        URI(url).authority
      end

      def get_schemes_from_base_url
        url = builder.requests.first.get_base_url

        [URI(url).scheme]
      end

      def get_base_path
        builder.requests.first.get_base_path

        # TODO: raise error if inconsistent
      end

      def build_tags_from_sections
        builder.sections.filter(&:contains_request?).map do |section|
          { name: section.name }
        end
      end
  end
end
