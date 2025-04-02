# frozen_string_literal: true

require "test_helper"

class Explicit::Request::ConveniencesTest < ActiveSupport::TestCase
  test "param description" do
    request = Explicit::Request.new do
      param :name, :string, description: "User full name"
    end

    assert_equal "User full name", request.params_type.attributes[:name].description
  end

  test "params default" do
    request = Explicit::Request.new do
      param :name, :string, default: "foo"
    end

    assert_equal "foo", request.params_type.attributes[:name].default
  end

  test "params optional" do
    request = Explicit::Request.new do
      param :name, :string, optional: true
    end

    assert_equal false, request.params_type.attributes[:name].required?
  end

  test "params default + optional" do
    request = Explicit::Request.new do
      param :name, :string, optional: true, default: "foo"
    end

    assert_equal "foo", request.params_type.attributes[:name].default
    assert_equal false, request.params_type.attributes[:name].required?
  end
end
