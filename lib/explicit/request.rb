# frozen_string_literal: true

class Explicit::Request
  attr_reader :routes, :headers, :params, :responses, :examples

  def initialize(&block)
    @routes = []
    @headers = {}
    @params = {}
    @responses = []
    @examples = []

    if Explicit.configuration.rescue_from_invalid_params?
      @responses << {
        status: [:literal, 422],
        data: {
          error: "invalid_params",
          params: [:hash, :string, :string]
        }
      }
    end

    instance_eval(&block)
  end

  def new(&block)
    subrequest = self.class.new { }

    subrequest.instance_variable_set(:@base_url,  @base_url)
    subrequest.instance_variable_set(:@base_path, @base_path)
    subrequest.instance_variable_set(:@routes,    @routes.dup)
    subrequest.instance_variable_set(:@headers,   @headers.dup)
    subrequest.instance_variable_set(:@params,    @params.dup)
    subrequest.instance_variable_set(:@responses, @responses.dup)
    subrequest.instance_variable_set(:@examples,  @examples.dup)

    subrequest.tap { _1.instance_eval(&block) }
  end

  def get(path)     = @routes << Route.new(method: :get, path:)
  def head(path)    = @routes << Route.new(method: :head, path:)
  def post(path)    = @routes << Route.new(method: :post, path:)
  def put(path)     = @routes << Route.new(method: :put, path:)
  def delete(path)  = @routes << Route.new(method: :delete, path:)
  def options(path) = @routes << Route.new(method: :options, path:)
  def patch(path)   = @routes << Route.new(method: :patch, path:)

  def base_url(url) = (@base_url = url)
  def get_base_url = @base_url

  def base_path(prefix) = (@base_path = prefix)
  def get_base_path = @base_path

  def title(text) = (@title = text)
  def get_title = @title || @routes.first.to_s

  def description(markdown) = (@description = markdown)
  def get_description = @description

  def header(name, spec)
    raise ArgumentError("duplicated header #{name}") if @headers.key?(name)

    @headers[name] = spec
  end

  def param(name, spec, **options)
    raise ArgumentError("duplicated param #{name}") if @params.key?(name)

    if options[:optional]
      spec = [:nilable, spec]
    end

    if (defaultval = options[:default])
      spec = [:default, defaultval, spec]
    end

    if (description = options[:description])
      spec = [:description, description, spec]
    end

    @params[name] = spec
  end

  def response(status, format)
    @responses << { status: [:literal, status], data: format }
  end

  def add_example(params:, response:, headers: {})
    raise ArgumentError.new("missing :status in response") if !response.key?(:status)
    raise ArgumentError.new("missing :data in response")   if !response.key?(:data)

    case responses_validator.call(response)
    in [:ok, _] then nil
    in [:error, err] then raise InvalidExampleError.new(err)
    end

    response = Response.new(response[:status], response[:data])

    @examples << Example.new(params:, headers:, response:)
  end

  def validate!(values)
    case params_validator.call(values)
    in [:ok, validated_data] then validated_data
    in [:error, err] then raise InvalidParamsError.new(err)
    end
  end

  def gid
    routes.first.to_s
  end

  private
    def params_validator
      @params_validator ||= Explicit::Spec.build(@params)
    end

    def headers_validator
      @headers_validator ||= Explicit::Spec.build(@headers)
    end

    def responses_validator
      @responses_validator ||= Explicit::Spec.build([:one_of, *@responses])
    end
end
