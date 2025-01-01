# frozen_string_literal: true

class Explicit::Type::Literal < Explicit::Type
  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def validate(value)
    if value == @value
      [:ok, value]
    else
      [:error, error_i18n("literal", value: @value.inspect)]
    end
  end

  def jsontype
    @value.inspect
    # @value.is_a?(::String) ? "string" : "integer"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/literal"
    end

    def has_details?
      true
    end
  end
end
