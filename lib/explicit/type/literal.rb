# frozen_string_literal: true

class Explicit::Type::Literal < Explicit::Type
  attr_reader :value

  def initialize(value:)
    if !value.is_a?(::String) && !value.is_a?(::Integer)
      raise ArgumentError("literal must be a string or integer") 
    end

    @value = value
  end

  def validate(value)
    if value == @value
      [:ok, value]
    else
      [:error, error_i18n("literal", value: @value.inspect)]
    end
  end

  concerning :Webpage do
    def summary
      @value.inspect
    end

    def partial
      nil
    end

    def has_details?
      false
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: @value.is_a?(::String) ? "string" : "integer",
        enum: [@value]
      })
    end
  end
end
