require "schema/api/documentation"
require "schema/api/engine"
require "schema/api/errors"
require "schema/api/test_helper"
require "schema/api/version"

require "schema/type"
require "schema/type/agreement"
require "schema/type/array"
require "schema/type/boolean"
require "schema/type/builder"
require "schema/type/date_time_iso8601"
require "schema/type/date_time_posix"
require "schema/type/default"
require "schema/type/inclusion"
require "schema/type/integer"
require "schema/type/literal"
require "schema/type/nilable"
require "schema/type/one_of"
require "schema/type/record"
require "schema/type/string"

module Schema
  class API
    class InvalidParamsError < RuntimeError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end
    end

    Route = ::Data.define(:method, :path)
    Response = ::Data.define(:status, :format)

    class << self
      def get(path)     = routes << Route.new(method: :get, path:)
      def head(path)    = routes << Route.new(method: :head, path:)
      def post(path)    = routes << Route.new(method: :post, path:)
      def put(path)     = routes << Route.new(method: :put, path:)
      def delete(path)  = routes << Route.new(method: :delete, path:)
      def options(path) = routes << Route.new(method: :options, path:)
      def patch(path)   = routes << Route.new(method: :patch, path:)

      def title(text)
        # TODO
      end

      def description(markdown)
        # TODO
      end

      def header(name, format)
        raise ArgumentError("duplicated header #{name}") if headers.key?(name)

        headers[name] = format
      end

      def param(name, format, **options)
        raise ArgumentError("duplicated param #{name}") if params.key?(name)

        params[name] = format
      end

      def response(status, format)
        responses << Response.new(status:, format:)
      end

      def validate!(values)
        schema = Schema::Type::Builder.build(params)

        case schema.call(values)
        in [:ok, validated_data] then validated_data
        in [:error, err] then raise InvalidParamsError.new(err)
        end
      end

      private
        def routes
          @routes ||= []
        end

        def headers
          @headers ||= {}
        end

        def params
          @params ||= {}
        end

        def responses
          @responses ||= []
        end
    end
  end
end
