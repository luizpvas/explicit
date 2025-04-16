# frozen_string_literal: true

require "time"

class Explicit::Type::DateTimeISO8601 < Explicit::Type
  attr_reader :min, :max

  Eval = ->(expr) { expr.respond_to?(:call) ? expr.call : expr }

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def validate(value)
    return error_i18n("date_time_iso8601") if !value.is_a?(::String)

    datetime = Time.iso8601(value)

    if min
      min_value = Eval[min]

      if datetime.before?(min_value)
        return error_i18n("date_time_iso8601_min", min: min_value)
      end
    end

    if max
      max_value = Eval[max]

      if datetime.after?(max_value)
        return error_i18n("date_time_iso8601_max", max: max_value)
      end
    end

    [:ok, datetime]
  rescue ArgumentError
    error_i18n("date_time_iso8601")
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

  concerning :MCP do
    def json_schema
      merge_base_json_schema({
        type: "string",
        format: "date-time",
        description_topics: [
          swagger_i18n("date_time_iso8601")
        ]
      })
    end
  end
end