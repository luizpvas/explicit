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
end
