# frozen_string_literal: true

require "test_helper"

class Schema::API::ErrorsTest < ActiveSupport::TestCase
  test "agreement" do
    assert_equal "must be accepted", translate_error(:agreement)
  end

  test "array" do
    assert_equal "invalid item at index(0): must be a string", translate_error([:array, 0, :string])
    assert_equal "must not be empty", translate_error(:empty)
  end

  test "boolean" do
    assert_equal "must be a boolean", translate_error(:boolean)
  end

  test "date_time_iso8601" do
    assert_equal "must be a valid iso8601 date time", translate_error(:date_time_iso8601)
  end

  test "date_time_posix" do
    assert_equal "must be a valid posix timestamps", translate_error(:date_time_posix)
  end

  test "inclusion" do
    assert_equal 'must be one of: ["foo", "bar"]', translate_error([:inclusion, ["foo", "bar"]])
  end

  test "integer" do
    assert_equal "must be an integer", translate_error(:integer)
    assert_equal "must be bigger than or equal to 2", translate_error([:min, 2])
    assert_equal "must be smaller than or equal to 2", translate_error([:max, 2])
    assert_equal "must not be negative", translate_error(:negative)
    assert_equal "must not be positive", translate_error(:positive)
  end

  test "string" do
    assert_equal "must be a string", translate_error(:string)
    assert_equal "must not be empty", translate_error(:empty)
    assert_equal "length must be greater than or equal to 2", translate_error([:minlength, 2])
    assert_equal "length must be smaller than or equal to 2", translate_error([:maxlength, 2])
    assert_equal "must have format /(foo|bar)/", translate_error([:format, /(foo|bar)/])
  end

  private
    def translate_error(error)
      Schema::API::Errors.translate(error, Schema::API::Errors::I18n)
    end
end
