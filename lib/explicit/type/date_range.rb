# frozen_string_literal: true

class Explicit::Type::DateRange < Explicit::Type
  attr_reader :min_range, :max_range, :min_date, :max_date

  FORMAT = /^(\d{4}-\d{2}-\d{2})\.\.(\d{4}-\d{2}-\d{2})$/.freeze

  Eval = ->(value) do
    value.respond_to?(:call) ? value.call : value
  end

  def initialize(min_range: nil, max_range: nil, min_date: nil, max_date: nil)
    @min_range = min_range
    @max_range = max_range
    @min_date = min_date
    @max_date = max_date
  end

  def validate(value)
    return [:error, error_i18n("string")] if !value.is_a?(::String)

    match = FORMAT.match(value)

    return [:error, error_i18n("date_range_format")] if !match

    date_1, date_2 = match.captures.map(&:to_date)

    if min_date
      min_date_value = Eval[min_date]

      if date_1 < min_date_value
        return [:error, error_i18n("date_range_min_date", min_date: min_date_value)]
      end
    end

    if max_date
      max_date_value = Eval[max_date]

      if date_2 > max_date_value
        return [:error, error_i18n("date_range_max_date", max_date: max_date_value)]
      end
    end

    if min_range
      diff_in_days = date_2 - date_1 + 1

      if diff_in_days < min_range.in_days
        return [:error, error_i18n("date_range_min_range", min_range: min_range.inspect)]
      end
    end

    if max_range
      diff_in_days = date_2 - date_1 + 1

      if diff_in_days > max_range.in_days
        return [:error, error_i18n("date_range_max_range", max_range: max_range.inspect)]
      end
    end

    [:ok, Range.new(date_1, date_2)]
  end

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/date_range"
    end

    def has_details?
      true
    end
  end

  concerning :Swagger do
    def swagger_schema
      merge_base_swagger_schema({
        type: "string",
        pattern: FORMAT.inspect[1..-2],
        format: "date range",
        description_topics: [
          swagger_i18n("date_range"),
          min_range&.then { swagger_i18n("date_range_min_range", min_range: _1.inspect) },
          max_range&.then { swagger_i18n("date_range_max_range", max_range: _1.inspect) },
        ]
      })
    end
  end
end
