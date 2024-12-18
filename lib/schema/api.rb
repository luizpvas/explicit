require "schema/api/version"
require "schema/api/engine"
require "schema/api/documentation"

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
require "schema/type/nilable"
require "schema/type/record"
require "schema/type/string"

module Schema
  class API
    InvalidParamsError = ::Class.new(::RuntimeError)

    class << self
      def header(name, spec)
        headers[name] = spec
      end

      def param(name, spec)
        raise ArgumentError("duplicated param #{name}") if params.key?(name)

        params[name] = spec
      end

      def validate!(values)
        schema = Schema::Type::Builder.build(params)

        case schema.call(values)
        in [:ok, validated_data] then validated_data
        in [:error, err] then raise InvalidParamsError.new(err)
        end
      end

      private
        def headers
          @headers ||= {}
        end

        def params
          @params ||= {}
        end
    end
  end
end
