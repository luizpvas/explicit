# 0.2.5

- Change documentation web page font from `sans-serif` to `system-ui`.

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
