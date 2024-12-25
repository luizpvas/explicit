# frozen_string_literal: true

require "time"

module Explicit::Spec::DateTimePosix
  extend self

  ERROR_INVALID = [:error, :date_time_posix].freeze

  def call(value)
    if !value.is_a?(::Integer) && !value.is_a?(::String)
      return ERROR_INVALID
    end

    datetimeval = DateTime.strptime(value.to_s, "%s")

    [:ok, datetimeval]
  rescue Date::Error
    ERROR_INVALID
  end
end
