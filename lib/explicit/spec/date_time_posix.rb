# frozen_string_literal: true

require "time"

class Explicit::Spec::DateTimePosix < Explicit::Spec
  ERROR_INVALID = [:error, :date_time_posix].freeze

  def validate(value)
    if !value.is_a?(::Integer) && !value.is_a?(::String)
      return ERROR_INVALID
    end

    datetimeval = DateTime.strptime(value.to_s, "%s")

    [:ok, datetimeval]
  rescue Date::Error
    ERROR_INVALID
  end
end
