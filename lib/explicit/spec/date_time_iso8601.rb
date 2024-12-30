# frozen_string_literal: true

require "time"

class Explicit::Spec::DateTimeISO8601 < Explicit::Spec
  def validate(value)
    return [:error, :date_time_iso8601] if !value.is_a?(::String)

    timeval = Time.iso8601(value)

    [:ok, timeval]
  rescue ArgumentError
    [:error, :date_time_iso8601]
  end
end
