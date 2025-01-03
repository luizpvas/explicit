# frozen_string_literal: true

class Explicit::Request
  Example = ::Data.define(:request, :params, :headers, :response) do
    def to_curl
      nil
    end
  end
end
