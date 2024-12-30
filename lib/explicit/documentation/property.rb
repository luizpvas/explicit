# frozen_string_literal: true

class Explicit::Documentation::Property
  attr_reader :name, :spec

  def initialize(name:, spec:)
    @name = name
    @spec = spec
  end

  def description_html
    case spec
    in [:description, markdown_text, _subspec]
      Explicit::Documentation::Markdown.to_html(markdown_text).html_safe
    else
      nil
    end
  end
end