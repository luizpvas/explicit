# frozen_string_literal: true

require "time"

class Explicit::Type::DateTimeISO8601 < Explicit::Type
  def validate(value)
    return [:error, error_i18n("date_time_iso8601")] if !value.is_a?(::String)

    timeval = Time.iso8601(value)

    [:ok, timeval]
  rescue ArgumentError
    [:error, error_i18n("date_time_iso8601")]
  end

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/date_time_iso8601"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: "string",
        format: "date-time",
        description_topics: [
          swagger_i18n("date_time_iso8601")
        ]
      })
    end
  end
end
