# Types

A type describes the shape of a value. When a value arrives — a request param,
a header, a response attribute — the type validates the input and coerces it
into the expected Ruby object. Types are runtime constructs and have no
relationship with static type checkers such as Sorbet or RBS.

Types are used extensively when [defining requests](requests.md), but they can
also be used on their own to validate any value.

1. [Usage](#usage)
2. [Customizing error messages](#customizing-error-messages)
3. [Available types](#available-types)
   - [Agreement](#agreement)
   - [Any](#any)
   - [Array](#array)
   - [BigDecimal](#bigdecimal)
   - [Boolean](#boolean)
   - [Date](#date)
   - [Date Range](#date-range)
   - [Date Time ISO8601](#date-time-iso8601)
   - [Date Time ISO8601 Range](#date-time-iso8601-range)
   - [Date Time Posix](#date-time-posix)
   - [Default](#default)
   - [Description](#description)
   - [Enum](#enum)
   - [File](#file)
   - [Float](#float)
   - [Hash](#hash)
   - [Integer](#integer)
   - [Literal](#literal)
   - [Nilable](#nilable)
   - [One of](#one-of)
   - [Record](#record)
   - [String](#string)

# Usage

Build a type with `Explicit::Type.build(spec)`, where `spec` is a data literal
in one of the formats described below, and then call `validate` on it. The
return value is a result tagged array: `[:ok, value]` if the value is valid or
`[:error, description]` if it is invalid.

```ruby
type = Explicit::Type.build([:string, empty: false])

type.validate("hello") # => [:ok, "hello"]
type.validate("")      # => [:error, "must not be empty"]
type.validate(nil)     # => [:error, "must be a string"]
```

On success, the value in `[:ok, value]` is validated **and coerced**. For
example, integer encoded strings are converted to `Integer`, and strings with
`strip: true` have leading and trailing whitespace removed:

```ruby
Explicit::Type.build(:integer).validate("42")
# => [:ok, 42]

Explicit::Type.build([:string, strip: true]).validate("  hello  ")
# => [:ok, "hello"]
```

On failure, `description` is a human readable error message. For composite
types such as [records](#record), the description mirrors the structure of the
input with an error message for each invalid attribute:

```ruby
type = Explicit::Type.build({ name: :string, age: [:integer, min: 0] })

type.validate({ name: "Bilbo", age: "111" })
# => [:ok, { name: "Bilbo", age: 111 }]

type.validate({ name: nil, age: -1 })
# => [:error, { name: "must be a string", age: "must be at least 0" }]
```

Error messages are translated using I18n and can be
[customized](#customizing-error-messages).

# Customizing error messages

Copy the [default error messages translations](https://github.com/luizpvas/explicit/blob/main/config/locales/en.yml)
to your project and make the desired changes.

# Available types

### Agreement

```ruby
:agreement
```

A boolean that must always be true. Useful for terms of use or agreement
acceptances. The following values are accepted: `true`, `"true"`, `"on"`, `"1"`
and `1`.

### Any

```ruby
:any
```

Allows all values, including null. Useful when documenting a proxy that
responds with whatever value the other service returned.

### Array

```ruby
[:array, subtype, options = {}]
[:array, :string]
[:array, :integer, empty: false]
```

All items in the array must be valid according to the subtype. If at least one
value is invalid then the array is invalid.

### BigDecimal

```ruby
:big_decimal
[:big_decimal, negative: false]
[:big_decimal, positive: true]
[:big_decimal, min: 0] # inclusive
[:big_decimal, max: 100] # inclusive
```

Value must be an integer or a string like `"0.2"` to avoid rounding errors.
[Reference](https://ruby-doc.org/stdlib-3.1.0/libdoc/bigdecimal/rdoc/BigDecimal.html)

### Boolean

```ruby
:boolean
```

The following values are true: `true`, `"true"`, `"on"`, `"1"` and `1`, and the
following values are false: `false`, `"false"`, `"off"`, `"0"` and `0`.

### Date

```ruby
:date
[:date, min: -> { 2.months.ago }]
[:date, max: -> { 1.month.from_now }]
```

A date in the format of `"YYYY-MM-DD"`.

### Date Range

```ruby
:date_range
[:date_range, min_range: 2.days]
[:date_range, max_range: 30.days]
[:date_range, min_date: -> { 2.months.ago }]
[:date_range, max_date: -> { 1.day.from_now }]
```

A range between two dates in the format of `"YYYY-MM-DD..YYYY-MM-DD"`.
The range is inclusive.

### Date Time ISO8601

```ruby
:date_time_iso8601
[:date_time_iso8601, min: -> { 2.months.ago }]
[:date_time_iso8601, max: -> { Time.current.end_of_day }]
```

String encoded date time following the ISO 8601 spec. For example:
`"2024-12-10T14:21:00Z"`

### Date Time ISO8601 Range

```ruby
:date_time_iso8601_range
[:date_time_iso8601_range, min_range: 30.minutes]
[:date_time_iso8601_range, max_range: 2.months]
[:date_time_iso8601_range, min_date_time: -> { 2.months.ago }]
[:date_time_iso8601_range, max_date_time: -> { 1.hour.from_now }]
```

A range between two date times in the format of
`"start_date_time..end_date_time"`. For example:
`"2024-12-10T14:00:00Z..2024-12-11T15:00:00Z"`. The range is inclusive.

### Date Time Posix

```ruby
:date_time_unix_epoch
[:date_time_unix_epoch, min: -> { 2.months.ago }]
[:date_time_unix_epoch, max: -> { Time.current.end_of_day }]
```

The number of elapsed seconds since January 1, 1970 in timezone UTC. For
example: `1733923153`

### Default

```ruby
[:default, default_value, subtype]
[:default, "USD", :string]
[:default, 0, :integer]
[:default, -> { Time.current.iso8601 }, :date_time_iso8601]
```

Provides a default value for the param if the value is not present or it is
`nil`. Other falsy values such as empty string or zero have precedence over
the default value.

If you provide a lambda it will execute every time `Request.validate!` is
called.

### Description

```ruby
[:description, markdown_text, subtype]
[:description, "Customer full name", :string]
[:description, "Rating score from 0 (bad) to 5 (good)", :integer]
```

Adds a description to the type. Descriptions are displayed in documentation
and do not affect validation in any way. There is no overhead at runtime.
Markdown supported.

### Enum

```ruby
[:enum, allowed_values]
[:enum, ["user", "admin"]]
[:enum, [10, 20, 30, 40, 50]]
```

### File

```ruby
:file
[:file, max_size: 2.megabytes]
[:file, content_types: %w[image/png image/jpeg]]
```

Value must be an uploaded file using "multipart/form-data" encoding.

### Float

```ruby
:float
[:float, negative: false]
[:float, positive: false]
[:float, min: 0] # inclusive
[:float, max: 10] # inclusive
```

Float encoded string alues such as "0.5" or "500.01" are automatically converted to `Float`.

### Hash

```ruby
[:hash, key_type, value_type, options = {}]
[:hash, :string, :string]
[:hash, :string, :integer]
[:hash, :string, :integer, empty: false]
[:hash, :string, [:array, :date_time_iso8601]]
```

Hashes are key value pairs where all keys must match key_type and all values must
match value_type. If you are expecting a hash with a specific set of keys use a
[record](#record) instead.

### Integer

```ruby
:integer
[:integer, negative: false]
[:integer, positive: false]
[:integer, min: 0] # inclusive
[:integer, max: 10] # inclusive
```

Integer encoded string values such as "10" or "-2" are automatically converted
to `Integer`.

### Literal

```ruby
[:literal, value]
[:literal, 6379]
[:literal, "value"]
"value" # strings are literal types, so you can use the shorter syntax.
```

A literal value behaves similar to an enum with a single value. Useful for
matching against multiple types in [`one_of`](#one-of).

### Nilable

```ruby
[:nilable, subtype]
[:nilable, :string]
[:nilable, [:array, :integer]]
```

Value must either match the subtype or be nil.

### One of

```ruby
[:one_of, type1, type2, ..., typeN]
[:one_of, :string, :integer]
[:one_of, { email: :string }, { phone_number: :string }]
```

Attempts to validate against each type in order stopping at the first type that
successfully matches the value. If none of the types match, an error is
returned.

### Record

```ruby
user_type = {
  name: :string,
  email: [:string, format: URI::MailTo::EMAIL_REGEXP]
}

address_type = {
  country_name: :string,
  zipcode: [:string, { format: /\d{6}-\d{3}/, strip: true }]
}

payment_type = {
  currency: [:nilable, :string], # use :nilable for optional attribute
  amount: :big_decimal
}
```

Records are hashes with predefined attributes. Records support recursive
definitions, that is, you can have records inside records, array of records,
records with array of records, etc.

### String

```ruby
:string
[:string, strip: true] # " foo " gets transformed to "foo"
[:string, empty: false]
[:string, downcase: true] # "FOO" gets transformed to "foo"
[:string, format: URI::MailTo::EMAIL_REGEXP]
[:string, min_length: 8] # inclusive
[:string, max_length: 20] # inclusive
```
