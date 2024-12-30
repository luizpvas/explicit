# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::PropTest < ActiveSupport::TestCase
  Prop = Explicit::Documentation::Prop

  test "agreement" do
    Prop.from_spec(:agreement).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("agreement", "explicit/spec/agreement", options: {}), prop
    end

    Prop.from_spec([:agreement, parse: true]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("agreement", "explicit/spec/agreement", options: { parse: true }), prop
    end
  end

  test "array" do
    Prop.from_spec([:array, :string]).tap do |prop|
      assert prop.renders_successfully?

      subprop = Prop.from_spec(:string)
      assert_equal Prop.with_details("array", "explicit/spec/array", subprop:, options: {}), prop
    end

    Prop.from_spec([:array, :string, empty: false]).tap do |prop|
      assert prop.renders_successfully?

      subprop = Prop.from_spec(:string)
      assert_equal Prop.with_details("array", "explicit/spec/array", subprop:, options: { empty: false }), prop
    end
  end

  test "bigdecimal" do
    Prop.from_spec(:bigdecimal).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("bigdecimal", "explicit/spec/bigdecimal", options: {}), prop
    end

    Prop.from_spec([:bigdecimal, min: 1, max: 100]) do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("bigdecimal", "explicit/spec/bigdecimal", options: { min: 1, max: 100 }), prop
    end
  end

  test "boolean" do
    Prop.from_spec(:boolean).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("boolean"), prop
    end

    Prop.from_spec([:boolean, parse: true]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("boolean", "explicit/spec/boolean", options: { parse: true }), prop
    end
  end

  test "date_time_iso8601" do
    Prop.from_spec(:date_time_iso8601).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("date_time_iso8601", "explicit/spec/date_time_iso8601", options: {}), prop
    end
  end

  test "date_time_posix" do
    Prop.from_spec(:date_time_posix).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("date_time_posix", "explicit/spec/date_time_posix", options: {}), prop
    end
  end

  test "default" do
    Prop.from_spec([:default, "foo", :string]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("string").with(default: "foo"), prop
    end
  end

  test "description" do
    Prop.from_spec([:description, "hello", :string]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("string").with(description: "hello"), prop
    end
  end

  test "hash" do
    Prop.from_spec([:hash, :string, :string]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal(
        Prop.with_details(
          "hash",
          "explicit/spec/hash",
          keyprop: Prop.just_name("string"),
          valueprop: Prop.just_name("string"),
          options: {}
        ),
        prop
      )
    end

    Prop.from_spec([:hash, :string, :string, empty: false]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal(
        Prop.with_details(
          "hash",
          "explicit/spec/hash",
          keyprop: Prop.just_name("string"),
          valueprop: Prop.just_name("string"),
          options: { empty: false }
        ),
        prop
      )
    end
  end

  test "inclusion" do
    Prop.from_spec([:inclusion, ["foo", "bar"]]).tap do |prop|
      assert prop.renders_successfully?

      assert_equal(
        Prop.with_details(
          "enum",
          "explicit/spec/inclusion",
          allowed_values: ["foo", "bar"]
        ).with(allowed_values: ["foo", "bar"]),
        prop
      )
    end
  end

  test "integer" do
    Prop.from_spec(:integer).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("integer"), prop
    end

    Prop.from_spec([:integer, min: 0]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("integer", "explicit/spec/integer", options: { min: 0 }), prop
    end
  end

  test "literal" do
    Prop.from_spec("foo").tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("constant \"foo\""), prop
    end

    Prop.from_spec([:literal, "foo"]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("constant \"foo\""), prop
    end
  end

  test "string" do
    Prop.from_spec(:string).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("string"), prop
    end

    Prop.from_spec([:string, empty: false]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.with_details("string", "explicit/spec/string", options: { empty: false }), prop
    end
  end
end