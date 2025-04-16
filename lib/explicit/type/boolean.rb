# frozen_string_literal: true

class Explicit::Type::Boolean < Explicit::Type
  VALUES = {
    true => true,
    "true" => true,
    "on" => true,
    "1" => true,
    1 => true,
    false => false,
    "false" => false,
    "off" => false,
    "0" => false,
    0 => false
  }.freeze

  def validate(value)
    value = VALUES[value]

    return error_i18n("boolean") if value.nil?

    [:ok, value]
  end

  concerning :Webpage do
    def summary
      "boolean"
    end

    def partial
      "explicit/documentation/type/boolean"
    end

    def has_details?
      true
    end
  end

  def swagger_schema
    merge_base_swagger_schema({
      type: "boolean"
    })
  end

  def json_schema
    merge_base_json_schema({
      type: "boolean"
    })
  end
end
