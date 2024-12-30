# frozen_string_literal: true

module Explicit::Documentation::Markdown
  extend self

  def to_html(markdown_text)
    ::Commonmarker.to_html(markdown_text, options: {
      parse: { smart: true },
      render: { hardbreaks: false }
    }).html_safe
  end
end