# frozen_string_literal: true

require "test_helper"

class Explicit::Documentation::MarkdownTest < ActiveSupport::TestCase
  test "markdown syntax in request description" do
    request = Explicit::Request.new do
      description <<-MD
        This is the first paragraph.
        Second line of the first paragraph.

        Third paragraph
      MD
    end

    page = Explicit::Documentation::Page::Request.new(request:)

    assert_equal [
      "<p>This is the first paragraph.",
      "Second line of the first paragraph.</p>",
      "<p>Third paragraph</p>"
    ], page.description_html.split("\n")
  end

  test "markdown syntax in param description" do
    request = Explicit::Request.new do
      param :name, :string, description: <<-MD
        This is the first paragraph.
        Second line of the first paragraph.

        Third paragraph
      MD
    end

    page = Explicit::Documentation::Page::Request.new(request:)

    assert_equal [
      "<p>This is the first paragraph.",
      "Second line of the first paragraph.</p>",
      "<p>Third paragraph</p>"
    ], page.params_properties.first.description_html.split("\n")
  end
end
