# frozen_string_literal: true

class Explicit::Request
  Route = ::Data.define(:method, :path)

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
      puts "adding a request with status #{status}"

      responses << { status: [:literal, status], data: format }
    end

    def validate!(values)
      params_validator = Explicit::Spec.build(params)

      case params_validator.call(values)
      in [:ok, validated_data] then validated_data
      in [:error, err] then raise InvalidParams::Error.new(err)
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

      INVALID_PARAMS_SPEC = {
        status: [:literal, 422],
        data: {
          error: "invalid_params",
          params: [:hash, :string, :string]
        }
      }.freeze

      def responses
        @responses ||= [INVALID_PARAMS_SPEC]
      end
  end
end
