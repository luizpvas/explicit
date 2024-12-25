# Schemax

Schemax is a validation and documentation library for JSON APIs that enforces
documented specs during runtime.

1. [Installation](#installation)
2. [Defining requests](#defining-requests)
3. [Reusing specs](#reusing-specs)
4. [Writing tests](#writing-tests)
5. [Writing documentation](#writing-documentation)
6. [Performance benchmark](#performance-benchmark)
7. Specs
   - [Agreement](#agreement)
   - [Array](#array)
   - [Boolean](#boolean)
   - [Date Time ISO8601](#date-time-iso8601)
   - [Date Time Posix](#date-time-posix)
   - [Default](#default)
   - [Hash](#hash)
   - [Inclusion](#inclusion)
   - [Integer](#integer)
   - [Literal](#literal)
   - [Nilable](#nilable)
   - [One of](#one-of)
   - [Record](#record)
   - [String](#string)
8. Advanced configuration
   - [Customizing error messages](#customizing-error-messages)
   - [Customizing error serialization](#customizing-error-serialization)

# Installation

Add the following line to your Gemfile and then run `bundle install`:

```ruby
gem "schemax", "~> 0.1"
```

# Defining requests

You define request specs by inheriting from `Schemax::Request`. The following
methods are available:

- `get(path)` - Adds a route to the request. Use the syntax `:param` for path
  params. For example: `get "/customers/:customer_id"`.
  - There is also `head`, `post`, `put`, `delete`, `options` and `patch` for
    other HTTP verbs.
- `title(text)` - Adds a title to the request. Displayed in the documentation.
- `description(text)` - Adds a description to the endpoint. Markdown supported.
- `header(name, schema)` - Adds a header to the endpoint.
- `param(name, spec, options = {})` - Adds the request param to the endpoint.
  It works for params in the request body, query string and path params.
- `response(status, spec)` - Adds a response schema. You can add multiple
  responses with different formats.

For example:

```ruby
class RegistrationsController < ActionController::API
  class Request < Schemax::Request
    post "/api/registrations"

    description <<-MD
    Attempts to register a new user in the system. If `payment_type` is not
    specified a trial period of 30 days is started.
    MD

    param :name, [:string, empty: false]
    param :email, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :payment_type, [:inclusion, ["free_trial", "credit_card"]], default: "free_trial"
    param :terms_of_use, :agreement

    response 200, { user: { id: :integer, email: :string } }
    response 422, { error: "email_already_taken" }
  end

  def create
    Request.validate!(params) => { name:, email:, payment_type: }

    user = User.create!(name:, email:, payment_type:)

    render json: user: { user.as_json(:id, :email) }
  rescue ActiveRecord::RecordNotUnique
    render json: { error: "email_already_taken" }, status: 422
  end
end
```

# Reusing specs

Specs are just data. You can reuse specs the same way you reuse constants or
configs in your app. For example:

```ruby
module MyApp::Spec
  UUID = [:string, { format: /^\h{8}-(\h{4}-){3}\h{12}$/ }].freeze
  EMAIL = [:string, { format: URI::MailTo::EMAIL_REGEXP }, strip: true }].freeze

  ADDRESS = {
    country_name: :string,
    zipcode: [:string, { format: /\d{6}-\d{3}/, strip: true }]
  }.freeze
end

class Request < Schemax::Request
  param :customer_uuid, MyApp::Spec::UUID
  param :email, MyApp::Spec::EMAIL
  param :address, MyApp::Spec::ADDRESS
end
```

# Writing tests

Include `Schemax::TestHelper` in your `test/test_helper.rb` or
`spec/rails_helper.rb`. This module provides the method
`fetch(request, params)` that let's you verify the endpoint works as expected
and that it responds with a valid response according to the spec.

Add the following line to your `test/test_helper.rb`.

```diff
module ActiveSupport
  class TestCase
    fixtures :all

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

+   include Schemax::TestHelper
  end
end
```

To test your controller, call `fetch(request, params:, headers:)` and write
assertions against the response. If the endpoint sends a response that does not
match expected spec the test fails with
`Schemax::Request::InvalidResponseError`.

The response object has a `status`, an integer value for the http status, and
`data`, a hash with the response data.

> Path params are matched by name, so if you have an endpoint configured with
> `put "/customers/:customer_id"` you must call as
> `fetch(CustomerController::UpdateRequest, { customer_id: 123 })`.

> Note: Response specs are only verified in test environment with no
> performance penalty when running in production.

```ruby
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "successful registration" do
    response = fetch(RegistrationsController::Request, params: {
      name: "Bilbo Baggins",
      email: "bilbo@shire.com",
      payment_type: "free_trial",
      terms_of_use: true
    })

    assert_equal 200, response.status

    assert response.data[:id]
    assert_equal "bilbo@shire.com", response.data[:email]
  end
end
```

# Writing documentation

Documentation is written . To make documentation available to users
you must configure it via `Schemax::Documentation.build` and then publish it
mounting it in `routes.rb`.

Inside `Schemax::Documentation.build` you have access to the following methods:

- `page_title(text)`
- `primary_color(hexcode)`
- `section(&block)`
- `add(request)`
- `add(title:, partial:)`

For example:

```ruby
module MyApp::API::V1
  Documentation = Schemax::Documentation.build do
    page_title "Acme Co. | API Docs"
    primary_color "#6366f1"

    section "Introduction" do
      add title: "About", partial: "api/v1/introduction/about"
    end

    section "Auth" do
      add SessionsController::CreateRequest
      add RegistrationsController::CreateRequest
    end

    section "Posts" do
      add PostsController::CreateRequest
      add PostsController::UpdateRequest
      add PostsController::DestroyRequest
    end
  end
end
```

`Schemax::Documentation.build` returns a rails engine that you can mount in
your `config/routes.rb`. For example:

```ruby
Rails.application.routes.draw do
  mount MyApp::API::V1::Documentation => "api/v1/docs"
end
```

# Specs

### Agreement

```ruby
:agreement
[:agreement, parse: true]
```

The `agreement` type is a boolean that must always be true. Useful for terms of
use or agreement acceptances. If `parse: true` is specified then the following
values are accepted alongisde `true`: "`true`", `"on"` and `"1"`.

### Array

```ruby
[:array, subspec, options = {}]
[:array, :string]
[:array, :integer, empty: false]
```

All items in the array must be valid according to the subspec. If at least one
value is invalid then the array is invalid.

### Boolean

```ruby
:boolean
[:boolean, parse: true]
```

If `parse: true` is specified then the following values are converted to `true`:
`"true"`, `"on"` and `"1"`, and the following values are converted to `false`:
`"false"`, `"off"` and `"0"`.

### Date Time ISO8601

```ruby
:date_time_iso8601
```

String encoded date time following the ISO 8601 spec. For example:
`"2024-12-10T14:21:00Z"`

### Date Time Posix

```ruby
:date_time_posix
```

The number of elapsed seconds since January 1, 1970 in timezone UTC. For
example: `1733923153`

### Default

```ruby
[:default, default_value, subspec]
[:default, "USD", :string]
[:default, 0, :integer]
[:default, -> { Time.current.iso8601 }, :date_time_iso8601]
```

Provides a default value for the param if the value is not present or it is
`nil`. Other falsy values such as empty string or zero have precedence over
the default value.

If you provide a lambda it will execute in every `validate!` call.

### Hash

```ruby
[:hash, keyspec, valuespec, options = {}]
[:hash, :string, :string]
[:hash, :string, :integer]
[:hash, :string, :integer, empty: false]
[:hash, :string, [:array, :date_time_iso8601]]
```

Hashes are key value pairs where all keys must match keyspec and all values must
match valuespec. If you are expecting a hash with a specific set of keys it is
best to use a [record](#record) instead.

### Inclusion

```ruby
[:inclusion, allowed_values]
[:inclusion, ["user", "admin"]]
[:inclusion, [10, 20, 30, 40, 50]]
```

Value must be present in the set of allowed values.

### Integer

```ruby
:integer
[:integer, parse: true]
[:integer, negative: false]
[:integer, positive: false]
[:integer, min: 0] # inclusive
[:integer, max: 10] # inclusive
```

If `parse: true` is specified then integer encoded string values such as "10" or
"-2" are automatically converted to integer.

### Literal

```ruby
[:literal, value]
[:literal, 6379]
[:literal, "value"]
"value" # literal strings can use shorter syntax
```

A literal value behaves similar to inclusion with a single value. Useful for
declaring multiple types in `one_of`.

### Nilable

```ruby
[:nilable, subspec]
[:nilable, :string]
[:nilable, [:array, :integer]]
```

Value must be `nil` or valid according to the subspec.

### One of

```ruby
[:one_of, spec1, spec2, ..., specN]
[:one_of, :string, :integer]
[:one_of, { email: :string }, { phone_number: :string }]
```

Attempts to validate against each spec in order stopping at the first spec that
successfully matches the value. If none of the specs match, an error is
returned.

### Record

```ruby
user_schema = {
  name: :string,
  email: [:string, format: URI::MailTo::EMAIL_REGEXP]
}

address_schema = {
  country_name: :string,
  zipcode: [:string, { format: /\d{6}-\d{3}/, strip: true }]
}

payment_schema = {
  currency: [:nilable, :string], # use :nilable for optional attribute
  amount: :bigdecimal
}
```

Records are hashes with predefined attributes. Records support recursive
definitions, that is, you can have records inside records, array of records,
records with array of records, etc.

### String

```ruby
:string
[:string, strip: true]
[:string, empty: false]
[:string, format: URI::MailTo::EMAIL_REGEXP]
[:string, minlength: 8] # inclusive
[:string, maxlength: 20] # inclusive
```
