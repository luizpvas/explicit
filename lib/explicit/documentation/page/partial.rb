# frozen_string_literal: true

module Explicit::Documentation::Page
  class Partial
    attr_reader :title, :partial

    def initialize(title:, partial:)
      @title = title
      @partial = partial
    end

    def request?
      false
    end

    def anchor
      title.dasherize
    end
  end
end
