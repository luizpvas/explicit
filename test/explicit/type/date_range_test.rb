# frozen_string_literal: true

require "test_helper"

class Explicit::Type::DateRangeTest < ActiveSupport::TestCase
  test "ok" do
    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", :date_range)
    )
  end

  test "min_date" do
    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", [:date_range, min_date: -> { "2025-01-08".to_date }])
    )

    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", [:date_range, min_date: "2025-01-08".to_date])
    )

    assert_error(
      "starting date must not be a day before 2025-01-08",
      validate("2025-01-07..2025-01-10", [:date_range, min_date: "2025-01-08".to_date])
    )
  end

  test "max_date" do
    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", [:date_range, max_date: -> { "2025-01-10".to_date }])
    )

    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", [:date_range, max_date: "2025-01-10".to_date])
    )

    assert_error(
      "ending date must not be a day after 2025-01-09",
      validate("2025-01-07..2025-01-10", [:date_range, max_date: "2025-01-09".to_date])
    )
  end

  test "min_range" do
    assert_ok(
      Range.new("2025-01-09".to_date, "2025-01-10".to_date),
      validate("2025-01-09..2025-01-10", [:date_range, min_range: 2.days])
    )

    assert_error(
      "must not be less than 2 days",
      validate("2025-01-10..2025-01-10", [:date_range, min_range: 2.days])
    )
  end

  test "max_range" do
    assert_ok(
      Range.new("2025-01-08".to_date, "2025-01-10".to_date),
      validate("2025-01-08..2025-01-10", [:date_range, max_range: 3.days])
    )

    assert_error(
      "must not be more than 3 days",
      validate("2025-01-07..2025-01-10", [:date_range, max_range: 3.days])
    )
  end

  test "error" do
    assert_error "must be a string", validate(nil, :date_range)
    assert_error 'must be a string in the format of "YYYY-MM-DD..YYYY-MM-DD"', validate("foo", :date_range)

    assert_error(
      "starting date must be the same day or a day before the ending date",
      validate("2025-01-08..2025-01-07", :date_range)
    )
  end

  test "swagger" do
    type = type(
      [
        :description,
        "desc",
        [
          :default,
          "2025-01-07..2025-01-10",
          [:date_range, min_range: 1.day, max_range: 30.days]
        ]
      ]
    )

    assert_equal type.swagger_schema, {
      type: "string",
      pattern: Explicit::Type::DateRange::FORMAT.inspect[1..-2],
      format: "date range",
      default: "2025-01-07..2025-01-10",
      description: <<~TXT.strip
        desc

        * The value must be a range between two dates in the format of: "YYYY-MM-DD..YYYY-MM-DD"
        * The range must not be less than 1 day
        * The range must not be more than 30 days
      TXT
    }
  end
end
