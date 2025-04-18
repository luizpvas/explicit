# frozen_string_literal: true

class Explicit::Type::Any < Explicit::Type
  def validate(value)
    [ :ok, value ]
  end

  concerning :Webpage do
    def summary
      "any"
    end

    def partial
      "explicit/documentation/type/any"
    end

    def has_details?
      false
    end
  end

  def json_schema(flavour)
    return {} if flavour == :swagger

    { type: "string" }
  end
end
