# frozen_string_literal: true

class Explicit::Request
  Example = ::Data.define(:request, :params, :headers, :response) do
    def to_curl_lines
      route = request.routes.first
      method = route.method.to_s.upcase
      path = route.replace_path_params(params)
      body_params = params.slice(*request.params_type.body_params_type.attributes.keys)
      query_params = params.slice(*request.params_type.query_params_type.attributes.keys)

      url = "#{request.get_base_url}#{request.get_base_path}#{path}#{query_params.present? ? "?#{query_params.to_query}" : ""}"
      curl_request = "curl -X#{method} \"#{url}\""

      curl_headers =
        if body_params.empty?
          []
        elsif request.accepts_file_upload?
          ['-H "Content-Type: multipart/form-data"']
        else
          ['-H "Content-Type: application/json"']
        end

      headers.each do |key, value|
        curl_headers << "-H \"#{key}: #{value}\""
      end

      curl_body =
        if body_params.empty?
          []
        elsif request.accepts_file_upload?
          file_params = request.params_type.attributes.filter do |name, type|
            type.is_a?(Explicit::Type::File)
          end.to_h

          non_file_params = body_params.except(*file_params.keys)

          curl_non_file_params = non_file_params.to_query.split("&").map do |key_value|
            "-F \"#{CGI.unescape(key_value).gsub('"', '\"')}\""
          end

          curl_file_params = file_params.map do |name, _|
            "-F #{name}=\"#{body_params[name]}\""
          end

          curl_non_file_params.concat(curl_file_params)
        else
          # https://stackoverflow.com/questions/34847981/curl-with-multiline-of-json
          ["-d @- << EOF\n#{JSON.pretty_generate(body_params)}\nEOF"]
        end

      [curl_request].concat(curl_headers).concat(curl_body)
    end
  end
end
