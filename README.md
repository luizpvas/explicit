# Spec::API

`spec-api` is a documentation and validation library for JSON APIs. It allows
you to document and specify the format of requests and responses, and test your
endpoints to make sure the specs are being followed.

1. [Installation](#installation)
1. [Defining specs](#defining-specs)
2. [Reusing specs](#reusing-specs)
3. [Writing tests](#writing-tests)
4. Types
    * [String](#string)
    * [Integer](#integer)
    * [Boolean](#boolean)
    * [Date Time ISO8601](#date-time-iso8601)
    * [Date Time Posix](#date-time-posix)
    * [Array](#array)
    * [Schema](#schema)
    * [Inclusion](#inclusion)
    * [Agreement](#agreement)
    * [Nilable](#nilable)
    * [Default](#default)

# Installation

Add the following line to your Gemfile:

```ruby
gem "spec-api", "~> 0.1"
```

# Defining specs

You define API specs by inheriting from `Spec::API`. Inside the class you add
documentation, param specs and response specs.

The following methods are available:

* `get(path)` - Adds a route to the spec. Use the syntax `/:param` for path
  params. For example: `get "/customers/:customer_id"`.
    * There is also `head`, `post`, `put`, `delete`, `options` and `patch` for
      other HTTP verbs.
* `description(text)` - Adds a description to the endpoint. Markdown supported.
* `header(name, spec)` - Adds a spec to the header.
* `param(name, spec)` - Adds a spec to the param. Works with request body
  payload, query strings and path params.
* `response(status, spec)` - Adds a response spec. You can add multiple
  responses with different formats. One of them must match in order to be valid.

For example:

```ruby
class RegistrationsController < ApplicationController
  class Spec < Spec::API
    post "/api/registrations"

    description <<-MD
    Attempts to register a new user in the system. If `payment_type` is not
    specified a trial period of 30 days is started for the account.
    MD

    param :name, [:string, empty: false]
    param :email, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :payment_type, [:inclusion, ["free_trial", "credit_card"]], default: "free_trial"
    param :terms_of_use, :agreement

    response 200, { user: { id: :integer, email: :string } }
    response 422, { error: "email_already_taken" }
    response 422, { error: "email_domain_blocked" }
  end

  def create
    validated_params = Spec.validate!(params)

    user = User.create!(validated_params)

    render json: user: { user.as_json(:id, :email) }
  rescue User::EmailTaken
    render json: { error: "email_already_taken" }, status: 422
  rescue User::BlockedEmailDomain
    render json: { error: "email_domain_blocked" }, status: 422
  end
end
```

# Reusing specs

Specs are just data. You can reuse specs the same way you reuse any constants
or config in your app. For example:

```ruby
module MyApp::Spec
  UUID = [:string, { format: /^\h{8}-(\h{4}-){3}\h{12}$/ }].freeze
  EMAIL = [:string, { format: URI::MailTo::EMAIL_REGEXP }, strip: true }].freeze

  ADDRESS = {
    country_name: :string,
    zipcode: [:string, { format: /\d{6}-\d{3}/, strip: true }]
  }.freeze
end

class Spec < Spec::API
  param :uuid, MyApp::Spec::UUID
  param :email, MyApp::Spec::EMAIL
  param :address, MyApp::Spec::ADDRESS
end
```

# Writing tests

Include `Spec::API::TestHelper` in your `test_helper.rb`. This module
provides the method `request(spec, params)` to test your JSON controllers.
When you test your endpoint using the `request` helper you verify that your app
works as expected (of course), but you also ensure you're following response
specs.

Add the following line to your `test/test_helper.rb`.

```diff
module ActiveSupport
  class TestCase
    fixtures :all

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

+   include Spec::API::RequestHelper
  end
end
```

To test your endpoint, call `request(spec, params)` and write assertions against
the response. If the endpoint sends a response that does not match expected
formats the test fails with `Spec::API::InvalidResponseFormat`.

The response object has a `status`, an integer value for the http status, and
`data`, a hash with the response data.

> You can pass both body and path params, just make sure the names match. For
example, for the endpoint `put "/customers/:customer_id"` you must call as
`request(CustomersController::Spec, { customer_id: 123 })`.

> Note: Response format verification only runs in test environment with no
performance penalty when running in production.

```ruby
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registers a user" do
    response = request(RegistrationsController::Spec, {
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

# Types

### String

```ruby
:string
[:string, strip: true]
[:string, empty: false]
[:string, format: URI::MailTo::EMAIL_REGEXP]
[:string, minlength: 8] # inclusive
[:string, maxlength: 20] # inclusive
```

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

### Agreement

```ruby
:agreement
[:agreement, parse: true]
```

The `agreement` type is a boolean that must always be true. Useful for terms of
use or agreement acceptances. If `parse: true` is specified then the following
values are accepted alongisde `true`: "`true`", `"on"` and `"1"`.

### Inclusion

```ruby
[:inclusion, allowed_values]
[:inclusion, ["user", "admin"]]
[:inclusion, [10, 20, 30, 40, 50]]
```

Value must be present in the set of allowed values.

### Array

```ruby
[:array, subspec, options = {}]
[:array, :string]
[:array, :integer, empty: false]
```

All items in the array must be valid according to the subspec. If at least one
value is invalid then the array is invalid.

### Schema

```ruby
user_spec = {
  name: :string,
  email: [:string, format: URI::MailTo::EMAIL_REGEXP]
}

address_spec = {
  country_name: :string,
  zipcode: [:string, { format: /\d{6}-\d{3}/, strip: true }]
}

payment_spec = {
  currency: [:nilable, :string], # use :nilable for optional attribute
  amount: :bigdecimal
}
```

Schemas are hashes with predefined attributes. All specs support recursive
definitions, that is, you can have schemas inside schemas, array of schemas,
schemas with array of schemas, etc.

### Nilable

```ruby
[:nilable, subspec]
[:nilable, :string]
[:nilable, [:array, :integer]]
```

Value must be `nil` or valid according to the subspec.

### Default

```ruby
[:default, default_value, subspec]
[:default, "USD", :string]
[:default, 0, :integer]
[:default, -> { Time.current.iso8601 }, :date_time_iso8601]
```

Provides a default value the param is not present in the request or the value is
nil. All other falsy values such as an empty string or zero have precedence over
the default value.

If you provide a lambda as the default value, the lambda gets executed everytime
`validate!` is called.
