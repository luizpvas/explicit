# 0.2.17

- Add config option to enable or disable CORS support in swagger endpoint.
  The config looks for the presence of `Rack::Cors` by default, which should
  fix conflicts with most applications.

# 0.2.16

- Add MCP server compatible with [Streamable HTTP transport](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports#streamable-http).
- Rename `add_example` to `example` to make it consistent with other method names.
  `add_example` still works as an alias to avoid breaking changes.
- Add support for `positive` and `negative` constraints for `big_decimal` type.
  All numeric types (`big_decimal`, `integer` and `float`) now support the
  same constraints.

# 0.2.15

- Add preflight request to /swagger endpoint to fix CORS issues with swagger UI.
- Use same host present in the webpage request instead of the host defined in
  `routes.default_url_options`
- Little improvements in the web documentation for `big_decimal` type.

# 0.2.14

- Fix type checking in `hash` and `record` types when value is either a `String` or `Array`.
- Display "nullable" visual indication in web docs.

# 0.2.13

- Fix: params in GET requests are now set in query string instead of body.
- Add config option, disabled by default, to raise errors when an example that
  does not match the expected type is added to the request.
- Add a third argument `options` to the `header` method that accepts
  `auth: :basic` or `auth: bearer`. This improves upon the authorization
  guessing logic based on the format's regex.
- Fix cURL examples with query string params and body params.

# 0.2.12

- UI improvements in web documentation.

# 0.2.11

- Fix web documentation template for `any` type.

# 0.2.10

- Add support for the type `any` that allows all values including `null`.

# 0.2.9

- Automatically defines a `:string` param for path params if user did not define on in the request.
- Fix string encoding problem in the documentation for literal types.
- Fix swagger `Authorization` header.
- In web documentation, link to `petstore.swagger.io` instead of JSON file.

# 0.2.8

- Fix translation errors when default locale is not `:en`
- Fix swagger `date` type swagger schema.
- Fix swagger output when no requests in the documentation defines `base_url` and `base_path`.
- Add `float` type with the same constraints as integers (min, max, negative and positive).
- Fully support all variations of `negative: false`, `negative: true`, `positive: false` and `positive: true`.

# 0.2.5

- Change documentation web page font from `sans-serif` to `system-ui`.
- Do not include invalid params response variant if request does not need
  any headers or params (fixes #16).
- Consistent multiword naming.
- Fix `array` type validation error message.
- Improve error returned from `one_of` when all subtypes are records (fixes #12).
- Add default value to swagger documentation (fixes #23)
- Accept `BigDecimal` values in `:big_decimal` type (fixes #26)
- Add `date_range` type (fixes #6).
- Add `date_time_iso8601_range` type (fixes #7).
- Add favicon to documentation webpage.
- Fix route listing clutter output when running `rails routes`.
- Omit default lambda value from swagger documentation (fixes #27).
- Fix swagger regex format (fixes #28).
- Add `min` and `max` options to `:date_time_iso8601` and `:date_time_posix`.
- Rename `date_time_posix` to `date_time_unix_epoch`.
- Add `date` type (fixes #31).

# 0.2.2

- Rename `inclusion` type to `enum`.
- Add `file` type with support for `max_size` and `content_types`.
- Rename `spec` to `type`. Even though it is less acurate I believe people will
  understand it better. Besides, the word spec has a strong correlation with
  tests in the Rails community.
- Add `downcase: true` option to string type. In documentation it displays an
  indication that the param is case insensitive.
- Rename env var used to save request examples from `EXPLICIT_PERSIST_EXAMPLES`
  to `UPDATE_REQUEST_EXAMPLES`.
- Add `company_logo_url(url)` to documentation builder.
- Add `version(semver)` to API documentation.
- Drop `parse: true` option from the types: `:agreement`, `:boolean` and
  `:integer`.
