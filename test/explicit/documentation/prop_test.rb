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

  test "description" do
    Prop.from_spec([:description, "hello", :string]).tap do |prop|
      assert prop.renders_successfully?
      assert_equal Prop.just_name("string").with(description: "hello"), prop
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