# 0.2.8

- Fix translation errors when default locale is not `:en`
- Fix swagger `date` type swagger schema.
- Fix swagger output when no requests in the documentation defines `base_url` and `base_path`.
- Add `float` type with the same constraints as integers (min, max, negative and positive).

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
