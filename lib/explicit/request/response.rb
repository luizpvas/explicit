# frozen_string_literal: true

class Explicit::Request
  Response = ::Data.define(:status, :data) do
    def dig(...) = data.dig(...)
  end
end
