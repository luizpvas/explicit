# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::PropTest < ActiveSupport::TestCase
  Prop = Explicit::Documentation::Prop

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