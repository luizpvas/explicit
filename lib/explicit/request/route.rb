# frozen_string_literal: true

class Explicit::Request
  Route = ::Data.define(:method, :path) do
    def to_s
      "#{method.to_s.upcase} #{path}"
    end
  end
end