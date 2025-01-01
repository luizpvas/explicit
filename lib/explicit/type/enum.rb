# frozen_string_literal: true

class Explicit::Type::Enum < Explicit::Type
  attr_reader :allowed_values

  def initialize(allowed_values)
    @allowed_values = allowed_values
  end

  def validate(value)
    if allowed_values.include?(value)
      [:ok, value]
    else
      [:error, error_i18n("enum", allowed_values: allowed_values.inspect)]
    end
  end

  def jsontype
    "string"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/enum"
    end

    def has_details?
      true
    end
  end
end
