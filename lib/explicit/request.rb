# frozen_string_literal: true

class Explicit::Request
  attr_reader :routes, :headers, :params, :responses, :examples

  def initialize(&block)
    @routes = []
    @headers = {}
    @params = {}
    @responses = Hash.new { |hash, key| hash[key] = [] }
    @examples = Hash.new { |hash, key| hash[key] = [] }

    instance_eval(&block)

    define_missing_path_params!

    if Explicit.configuration.rescue_from_invalid_params? && @params.any?
      @responses[422] << {
        error: "invalid_params",
        params: [
          :description,
          "An object containing error messages for all invalid params",
          [ :hash, :string, :string ]
        ]
      }
    end
  end

  def new(&block)
    this = self

    self.class.new do
      instance_variable_set(:@base_url,  this.get_base_url)
      instance_variable_set(:@base_path, this.get_base_path)
      instance_variable_set(:@routes,    this.routes.dup)
      instance_variable_set(:@headers,   this.headers.dup)
      instance_variable_set(:@params,    this.params.dup)

      this.responses.each do |status, types|
        @responses[status] = types.dup
      end

      this.examples.each do |status, examples|
        @examples[status] = examples.dup
      end

      instance_eval(&block)
    end
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

  def header(name, type,  **options)
    raise ArgumentError("duplicated header #{name}") if @headers.key?(name)

    if (auth_type = options[:auth])
      type = [ :_auth_type, auth_type, type ]
    end

    @headers[name] = type
  end

  def param(name, type, **options)
    raise ArgumentError("duplicated param #{name}") if @params.key?(name)

    if options[:optional]
      type = [ :nilable, type ]
    end

    if (defaultval = options[:default])
      type = [ :default, defaultval, type ]
    end

    if (description = options[:description])
      type = [ :description, description, type ]
    end

    if @routes.first&.params&.include?(name)
      type = [ :_param_location, :path, type ]
    elsif @routes.first&.accepts_request_body?
      type = [ :_param_location, :body, type ]
    else
      type = [ :_param_location, :query, type ]
    end

    @params[name] = type
  end

  def response(status, typespec)
    @responses[status] << typespec
  end

  def add_example(params:, response:, headers: {})
    raise ArgumentError.new("missing :status in response") if !response.key?(:status)
    raise ArgumentError.new("missing :data in response")   if !response.key?(:data)

    status, data = response.values_at(:status, :data)

    response = Response.new(status:, data:)

    case responses_type(status:).validate(data)
    in [:ok, _]
      nil

    in [:error, err]
      if ::Explicit.configuration.raise_on_invalid_example?
        raise InvalidResponseError.new(response, err)
      else
        ::Rails.logger.error("[Explicit] Invalid response for #{gid} with status #{status}: #{err}")
      end
    end

    @examples[response.status] << Example.new(request: self, params:, headers:, response:)
  end

  def validate!(values)
    case params_type.validate(values)
    in [:ok, validated_data] then validated_data
    in [:error, err] then raise InvalidParamsError.new(err)
    end
  end

  def gid
    routes.first.to_s
  end

  def accepts_file_upload?
    params_type.attributes.any? do |name, type|
      type.is_a?(Explicit::Type::File)
    end
  end

  def headers_type
    @headers_type ||= Explicit::Type.build(@headers)
  end

  def params_type
    @params_type ||= Explicit::Type.build(@params)
  end

  def responses_type(status:)
    Explicit::Type.build([ :one_of, *@responses[status] ])
  end

  def custom_authorization_format?
    @headers.key?("Authorization") && !requires_basic_authorization? && !requires_bearer_authorization?
  end

  def requires_basic_authorization?
    authorization = headers_type.attributes["Authorization"]

    authorization&.auth_basic? || authorization&.format&.to_s&.include?("Basic")
  end

  def requires_bearer_authorization?
    authorization = headers_type.attributes["Authorization"]

    authorization&.auth_bearer? || authorization&.format&.to_s&.include?("Bearer")
  end

  private
    def define_missing_path_params!
      @routes.first&.params&.each do |path_param_name|
        if @params[path_param_name.to_sym].blank?
          param(path_param_name.to_sym, :string)
        end
      end
    end
end
