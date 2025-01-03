# frozen_string_literal: true

require "test_helper"

class Explicit::Request::ConveniencesTest < ActiveSupport::TestCase
  test "param description" do
    request = Explicit::Request.new do
      param :name, :string, description: "User full name"
    end

    assert_equal [:description, "User full name", :string], request.params[:name]
  end

  test "params default" do
    request = Explicit::Request.new do
      param :name, :string, default: "foo"
    end

    assert_equal [:default, "foo", :string], request.params[:name]
  end

  test "params optional" do
    request = Explicit::Request.new do
      param :name, :string, optional: true
    end

    assert_equal [:nilable, :string], request.params[:name]
  end

  test "params default + optional" do
    request = Explicit::Request.new do
      param :name, :string, optional: true, default: "foo"
    end

    assert_equal [:default, "foo", [:nilable, :string]], request.params[:name]
  end

  test "param in path" do
    request = Explicit::Request.new do
      post "/articles/:id"

      param :id, :integer
    end

    assert_equal [:_param_location, :path, :integer], request.params[:id]
  end
end