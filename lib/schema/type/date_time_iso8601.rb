# frozen_string_literal: true

require "time"

module Schema::Type::DateTimeISO8601
  extend self

  def call(value)
    return [:error, :date_time_iso8601] if !value.is_a?(::String)

    timeval = Time.iso8601(value)

    [:ok, timeval]
  rescue ArgumentError
    [:error, :date_time_iso8601]
  end
end
