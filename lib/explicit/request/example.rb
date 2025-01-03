# frozen_string_literal: true

class Explicit::Request
  Example = ::Data.define(:request, :params, :headers, :response) do
    def to_curl_lines
      route = request.routes.first
      method = route.method.to_s.upcase
      path = route.replace_path_params(params)
      url = "#{request.get_base_url}#{request.get_base_path}#{path}"
      curl_request = "curl -X#{method} \"#{url}\""

      body_params = params.except(*route.params)

      curl_headers =
        if body_params.empty?
          []
        else
          ['-H "Content-Type: application/json"']
        end

      headers.each do |key, value|
        curl_headers << "-H \"#{key}: #{value}\""
      end

      curl_body =
        if body_params.empty?
          []
        else
          ["-d '#{JSON.pretty_generate(params)}'"]
        end

      [curl_request].concat(curl_headers).concat(curl_body)
    end
  end
end
