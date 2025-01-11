# frozen_string_literal: true

class Explicit::Type::DateTimeISO8601Range < Explicit::Type
  attr_reader :min_range, :max_range, :min_date_time, :max_date_time

  def initialize(min_range: nil, max_range: nil, min_date_time: nil, max_date_time: nil)
    @min_range = min_range
    @max_range = max_range
    @min_date_time = min_date_time
    @max_date_time = max_date_time
  end

  Parse = ->(str) do
    Time.iso8601(str)
  rescue ArgumentError
    nil
  end

  Eval = ->(value) do
    value.respond_to?(:call) ? value.call : value
  end

  def validate(value)
    return [:error, error_i18n("string")] if !value.is_a?(::String)

    parts = value.split("..")

    if parts.size != 2
      return [:error, error_i18n("date_time_iso8601_range_format")] 
    end

    date_time_1, date_time_2 = parts.map(&Parse)

    if date_time_1.nil? || date_time_2.nil?
      return [:error, error_i18n("date_time_iso8601_range_format")]
    end

    if date_time_1.after?(date_time_2)
      return [:error, error_i18n("date_time_iso8601_range_inverted")]
    end

    if min_date_time
      min_date_time_value = Eval[min_date_time]

      if date_time_1 < min_date_time_value
        return [:error, error_i18n("date_time_iso8601_range_min_date_time", min_date_time: min_date_time_value)]
      end
    end

    if max_date_time
      max_date_time_value = Eval[max_date_time]

      if date_time_2 > max_date_time_value
        return [:error, error_i18n("date_time_iso8601_range_max_date_time", max_date_time: max_date_time_value)]
      end
    end

    if min_range
      min_range_value = Eval[min_range]

      diff_in_seconds = date_time_2 - date_time_1

      if diff_in_seconds < min_range_value.in_seconds
        return [:error, error_i18n("date_time_iso8601_range_min_range", min_range: min_range_value.inspect)]
      end
    end

    if max_range
      max_range_value = Eval[max_range]

      diff_in_seconds = date_time_2 - date_time_1

      if diff_in_seconds > max_range_value.in_seconds
        return [:error, error_i18n("date_time_iso8601_range_max_range", max_range: max_range_value.inspect)]
      end
    end

    [:ok, Range.new(date_time_1, date_time_2)]
  end

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/date_time_iso8601_range"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: "string",
        format: "date time range",
        description_topics: [
          swagger_i18n("date_time_iso8601_range"),
          min_range&.then { swagger_i18n("date_time_iso8601_range_min_range", min_range: _1.inspect) },
          max_range&.then { swagger_i18n("date_time_iso8601_range_max_range", max_range: _1.inspect) },
        ]
      })
    end
  end
end
