# frozen_string_literal: true

class Explicit::Type::Date < Explicit::Type
  attr_reader :min, :max

  Eval = ->(expr) { expr.respond_to?(:call) ? expr.call : expr }

  def initialize(min: nil, max: nil)
    @min = min
    @max = max
  end

  def validate(value)
    return [ :ok, value ] if value.is_a?(::Date)
    return error_i18n("string") if !value.is_a?(::String)

    date = ::Date.parse(value, false)

    if min
      min_value = Eval[min]

      if date.before?(min_value)
        return error_i18n("date_min", min: min_value)
      end
    end

    if max
      max_value = Eval[max]

      if date.after?(max_value)
        return error_i18n("date_max", max: max_value)
      end
    end

    [ :ok, date ]
  rescue ::Date::Error
    error_i18n("date_format")
  end

  concerning :Webpage do
    def summary
      "string"
    end

    def partial
      "explicit/documentation/type/date"
    end

    def has_details?
      true
    end
  end

  def swagger_schema
    merge_base_swagger_schema({
      type: "string",
      pattern: /\d{4}-\d{2}-\d{2}/.inspect[1..-2],
      format: "date",
      description_topics: [
        swagger_i18n("date_format")
      ]
    })
  end

  def json_schema
    merge_base_json_schema({
      type: "string",
      pattern: /\d{4}-\d{2}-\d{2}/.inspect[1..-2],
      format: "date",
      description_topics: [
        swagger_i18n("date_format")
      ]
    })
  end
end
