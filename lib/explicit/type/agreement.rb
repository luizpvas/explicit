# frozen_string_literal: true

class Explicit::Type::Agreement < Explicit::Type
  VALUES = [true, "true", "on", "1", 1].freeze
  OK = [:ok, true].freeze

  def validate(value)
    if VALUES.include?(value)
      OK
    else
      error_i18n("agreement")
    end
  end

  concerning :Webpage do
    def summary
      "boolean"
    end

    def partial
      "explicit/documentation/type/agreement"
    end

    def has_details?
      true
    end
  end

  def json_schema(flavour)
    {
      type: "boolean",
      description_topics: [
        swagger_i18n("agreement")
      ]
    }
  end
end
