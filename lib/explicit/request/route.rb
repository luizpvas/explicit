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

    def replace_path_params(values)
      values.reduce(path) do |acc_path, (key, value)|
        acc_path.gsub(":#{key}", value.to_s)
      end
    end
  end
end