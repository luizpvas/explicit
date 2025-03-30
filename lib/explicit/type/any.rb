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

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({})
    end
  end
end
