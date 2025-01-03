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

  def jsontype
    "string"
  end

  concerning :Webpage do
    def partial
      "explicit/documentation/type/date_time_iso8601"
    end

    def has_details?
      true
    end
  end
end
