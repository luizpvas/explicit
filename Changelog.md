# 0.2.2

- Rename `inclusion` spec to `enum`.
- Add `file` spec with support for `maxsize` and `mime`.
- Rename `spec` to `type`. Even though it is less acurate I believe people will
  understand it quicker. Besides, the workd spec has a strong correlation with
  tests in the Rails community.
- Add `downcase: true` option to string type.
- Rename env var used to save request examples from `EXPLICIT_PERSIST_EXAMPLES`
  to `UPDATE_REQUEST_EXAMPLES`.
- Add `company_logo_url(url)` to documentation builder.
