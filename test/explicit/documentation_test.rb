# frozen_string_literal: true

require "test_helper"

class Explicit::DocumentationTest < ActiveSupport::TestCase
  test "sections" do
    request = Explicit::Request.new { }

    documentation = build_documentation do
      section "one" do
        add title: "One", partial: "one"
      end

      section "two" do
        add request
      end
    end

    assert_equal 2, documentation.sections.size

    section_1 = documentation.sections.first
    assert_equal "one", section_1.name
    assert_not section_1.pages.first.request?
    assert_equal "one", section_1.pages.first.partial

    section_2 = documentation.sections.second
    assert_equal "two", section_2.name
    assert section_2.pages.first.request?
    assert_equal request, section_2.pages.first.request
  end

  private
    def build_documentation(&block)
      ::Explicit::Documentation::Builder.new.tap { _1.instance_eval &block }
    end
end
