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

    def accepts_request_body?
      method == :post || method == :put || method == :patch
    end

    def replace_path_params(values)
      values.reduce(path) do |acc_path, (key, value)|
        acc_path.gsub(":#{key}", value.to_s)
      end
    end

    def path_with_curly_syntax
      params.reduce(path) do |acc_path, param|
        acc_path.gsub(":#{param}", "{#{param}}")
      end
    end
  end
end
