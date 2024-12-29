# frozen_string_literal: true

module Explicit::Documentation::Markdown
  extend self

  def render(markdown_text)
    offset = 0
    markdown_text.each_char do |ch|
      break if ch != " "

      offset += 1
    end

    markdown_text = markdown_text.each_line.map do |line|
      line[offset..-1] || "\n"
    end

    ::Commonmarker.to_html(markdown_text.join, options: {
      parse: { smart: true },
      render: { hardbreaks: false }
    }).html_safe
  end
end