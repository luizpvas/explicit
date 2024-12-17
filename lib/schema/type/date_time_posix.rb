# frozen_string_literal: true

require "time"

module Schema::Type::DateTimePosix
  extend self

  def call(value)
    if !value.is_a?(::Integer) && !value.is_a?(::String)
      return [:error, :date_time_posix]
    end

    datetimeval = DateTime.strptime(value.to_s, "%s")

    [:ok, datetimeval]
  rescue Date::Error
    [:error, :date_time_posix]
  end
end
