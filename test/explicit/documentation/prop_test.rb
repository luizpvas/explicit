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