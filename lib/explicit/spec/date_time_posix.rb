# frozen_string_literal: true

require "time"

class Explicit::Spec::DateTimePosix < Explicit::Spec
  def validate(value)
    if !value.is_a?(::Integer) && !value.is_a?(::String)
      return [:error, error_i18n("date_time_posix")]
    end

    datetimeval = DateTime.strptime(value.to_s, "%s")

    [:ok, datetimeval]
  rescue Date::Error
    return [:error, error_i18n("date_time_posix")]
  end
end
