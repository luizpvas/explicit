# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok "2024-01-15".to_date, validate("2024-01-15", :date)
    assert_ok "2024-08-30".to_date, validate("2024-08-30", :date)
  end

  test "min" do
    assert_ok(
      "2024-01-15".to_date,
      validate("2024-01-15", [:date, min: -> { "2024-01-15".to_date }])
    )

    assert_error(
      "must not be a date before 2024-01-15",
      validate("2024-01-14", [:date, min: "2024-01-15".to_date])
    )
  end

  test "max" do
    assert_ok(
      "2024-01-15".to_date,
      validate("2024-01-15", [:date, max: -> { "2024-01-15".to_date }])
    )

    assert_error(
      "must not be a date after 2024-01-15",
      validate("2024-01-16", [:date, max: "2024-01-15".to_date])
    )
  end

  test "error" do
    assert_error "must be a string", validate(nil, :date)
    assert_error "must be a date in the format \"YYYY-MM-DD\"", validate("foo", :date)
  end

  test "swagger_schema" do
    type = type([
      :description,
      "desc",
      [:default, "2024-01-15", :date]
    ])

    assert type.swagger_schema, {
      type: "string",
      pattern: /\d{4}-\d{2}-\d{2}/.inspect[1..-2],
      format: "date",
      description: <<~TXT.strip
        desc

        * A date in the format of "YYYY-MM-DD"
      TXT
    }
  end

  test "json_schema" do
    type = type([
      :description,
      "desc",
      [:default, "2024-01-15", :date]
    ])

    assert type.json_schema, {
      type: "string",
      pattern: /\d{4}-\d{2}-\d{2}/.inspect[1..-2],
      format: "date",
      description: <<~TXT.strip
        desc

        * A date in the format of "YYYY-MM-DD"
      TXT
    }
  end
end
