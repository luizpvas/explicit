# frozen_string_literal: true

class Explicit::Request
  Route = ::Data.define(:method, :path) do
    def to_s
      "#{method.to_s.upcase} #{path}"
    end

    def params
      path.split("/").filter_map do |part|
        part[1..-1].to_sym if part.start_with?(":")
      end
    end
  end
end