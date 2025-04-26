# frozen_string_literal: true

require "time"

class Explicit::Type::DateTimeUnixEpoch < Explicit::Type
  attr_reader :min, :max

  Eval = ->(expr) { expr.respond_to?(:call) ? expr.call : expr }

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def validate(value)
    if !value.is_a?(::Integer) && !value.is_a?(::String)
      return error_i18n("date_time_unix_epoch")
    end

    datetime = DateTime.strptime(value.to_s, "%s")

    if min
      min_value = Eval[min]

      if datetime.before?(min_value)
        return error_i18n("date_time_unix_epoch_min", min: min_value)
      end
    end

    if max
      max_value = Eval[max]

      if datetime.after?(max_value)
        return error_i18n("date_time_unix_epoch_max", max: max_value)
      end
    end

    [:ok, datetime]
  rescue ::Date::Error
    return error_i18n("date_time_unix_epoch")
  end

  concerning :Webpage do
    def summary
      "integer"
    end

    def partial
      "explicit/documentation/type/date_time_unix_epoch"
    end

    def has_details?
      true
    end
  end

  def json_schema(flavour)
    {
      type: "integer",
      minimum: 1,
      format: "POSIX time",
      description_topics: [
        swagger_i18n("date_time_unix_epoch")
      ]
    }
  end
end
