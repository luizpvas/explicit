# frozen_string_literal: true

module Explicit::Documentation
  Section = ::Data.define(:name, :pages) do
    def contains_request?
      pages.any?(&:request?)
    end
  end
end
