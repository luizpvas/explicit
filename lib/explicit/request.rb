# frozen_string_literal: true

class Explicit::Request
  attr_reader :routes, :headers, :params, :responses

  def initialize(&block)
    @routes = []
    @headers = {}
    @params = {}
    @responses = [{
      status: [:literal, 422],
      data: {
        error: "invalid_params",
        params: [:hash, :string, :string]
      }
    }]

    instance_eval(&block)
  end

  def new(&block)
    subrequest = self.class.new { }

    subrequest.instance_variable_set(:@routes,    @routes.dup)
    subrequest.instance_variable_set(:@headers,   @headers.dup)
    subrequest.instance_variable_set(:@params,    @params.dup)
    subrequest.instance_variable_set(:@responses, @responses.dup)

    subrequest.tap { _1.instance_eval(&block) }
  end

  def get(path)     = @routes << Route.new(method: :get, path:)
  def head(path)    = @routes << Route.new(method: :head, path:)
  def post(path)    = @routes << Route.new(method: :post, path:)
  def put(path)     = @routes << Route.new(method: :put, path:)
  def delete(path)  = @routes << Route.new(method: :delete, path:)
  def options(path) = @routes << Route.new(method: :options, path:)
  def patch(path)   = @routes << Route.new(method: :patch, path:)

  def title(text)
    @title = text
  end

  def get_title
    @title || @routes.first.to_s
  end

  def description(markdown)
    @description = markdown
  end

  def get_description
    @description
  end

  def header(name, format)
    raise ArgumentError("duplicated header #{name}") if @headers.key?(name)

    @headers[name] = format
  end

  def param(name, format, **options)
    raise ArgumentError("duplicated param #{name}") if @params.key?(name)

    @params[name] = format
  end

  def response(status, format)
    @responses << { status: [:literal, status], data: format }
  end

  def validate!(values)
    # TODO: cache the validator instead of building it in every request
    params_validator = Explicit::Spec.build(@params)

    case params_validator.call(values)
    in [:ok, validated_data] then validated_data
    in [:error, err] then raise InvalidParams::Error.new(err)
    end
  end

  def gid
    routes.first.to_s
  end
end
