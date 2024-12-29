# Explicit

Explicit is a validation and documentation library for JSON APIs that enforces
documented specs at runtime.

1. [Installation](#installation)
2. [Defining requests](#defining-requests)
3. [Reusing specs](#reusing-specs)
4. [Reusing requests](#reusing-requests)
5. [Writing tests](#writing-tests)
6. [Publishing documentation](#publishing-documentation)
   - [Adding request examples](#adding-request-examples)
7. Specs
   - [Agreement](#agreement)
   - [Array](#array)
   - [BigDecimal](#bigdecimal)
   - [Boolean](#boolean)
   - [Date Time ISO8601](#date-time-iso8601)
   - [Date Time Posix](#date-time-posix)
   - [Default](#default)
   - [Description](#description)
   - [Hash](#hash)
   - [Inclusion](#inclusion)
   - [Integer](#integer)
   - [Literal](#literal)
   - [Nilable](#nilable)
   - [One of](#one-of)
   - [Record](#record)
   - [String](#string)
8. [Configuration](#configuration)
   - [Changing examples file path](#changing-examples-file-path)
   - [Customizing error messages](#customizing-error-messages)
   - [Customizing error serialization](#customizing-error-serialization)
9. [Performance benchmark](#performance-benchmark)

# Installation

Add the following line to your Gemfile and then run `bundle install`:

```ruby
gem "explicit", "~> 0.1"
```

# Defining requests

Call `Explicit::Request.new` to define a request. The following methods are
available:

- `get(path)` - Adds a route to the request. Use the syntax `/:param` for path
  params.
  - There is also `head`, `post`, `put`, `delete`, `options` and `patch` for
    other HTTP verbs.
- `title(text)` - Adds a title to the request. Displayed in documentation.
- `description(text)` - Adds a description to the endpoint. Displayed in
  documentation. Markdown supported.
- `header(name, spec)` - Adds a spec to the request header.
- `param(name, spec, options = {})` - Adds a spec to the request param.
  It works for params in the request body, query string and path params.
- `response(status, spec)` - Adds a response spec. You can add multiple
  responses with different formats.
- `add_example(params:, headers:, response:)` - Adds an example to the
  documentation. [See more details here](#adding-request-examples).
- `base_url(url)` - Sets the host for this API. For example: "https://api.myapp.com".
  Meant to be used with [request composition](#reusing-requests).
- `base_path(prefix)` - Sets a prefix for the routes. For example: "/api/v1".
  Meant to be used with [request composition](#reusing-requests).

For example:

```ruby
class RegistrationsController < ActionController::API
  Request = Explicit::Request.new do
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

    render json: { user: user.as_json(only: %[id email]) }
  rescue ActiveRecord::RecordNotUnique
    render json: { error: "email_already_taken" }, status: 422
  end
end
```

# Reusing specs

Specs are just data. You can share specs the same way you reuse constants or
configs in your app. For example:

```ruby
module MyApp::Spec
  UUID = [:string, format: /^\h{8}-(\h{4}-){3}\h{12}$/].freeze
  EMAIL = [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true].freeze

  ADDRESS = {
    country_name: [:string, empty: false],
    zipcode: [:string, format: /\d{6}-\d{3}/]
  }.freeze
end

# ... and then reference the shared specs when needed
Request = Explicit::Request.new do
  param :customer_uuid, MyApp::Spec::UUID
  param :email, MyApp::Spec::EMAIL
  param :address, MyApp::Spec::ADDRESS
end
```

# Reusing requests

Sometimes it is useful to share a group of params, headers or responses between
requests. You can achieve this by instantiating requests from an existing
request instead of `Explicit::Request`. For example:

```ruby
AuthenticatedRequest = Explicit::Request.new do
  header "Authorization", [:string, format: /Bearer [a-zA-Z0-9]{20}/]

  response 403, { error: "unauthorized" }
end

Request = AuthenticatedRequest.new do
  # Request inherits all definitions from AuthenticatedRequest.
  # Any change you make to params, headers, responses or examples will add to
  # existing definitions.
end
```

# Writing tests

Include `Explicit::TestHelper` in your `test/test_helper.rb` or
`spec/rails_helper.rb`. This module provides the method
`fetch(request, **options)` that let's you verify the endpoint works as
expected and that it responds with a valid response according to the spec.

<details open>
  <summary>For Minitest users, add the following line to your <code>test/test_helper.rb</code></summary>

```diff
module ActiveSupport
  class TestCase
    fixtures :all

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

+   include Explicit::TestHelper
  end
end
```

</details>

<details open>
  <summary>For RSpec users, add the following line to your <code>spec/rails_helper.rb</code></summary>

```diff
RSpec.configure do |config|
+  config.include Explicit::TestHelper
end
```

</details>

To test your controller, call `fetch(request, **options)` and write
assertions against the response. If the response is invalid according to the
spec the test fails with `Explicit::Request::InvalidResponseError`.

The response object has a `status`, an integer value for the http status, and
`data`, a hash with the response data. It also provides `dig` for a
slighly shorter syntax when accessing nested attributes.

> Path params are matched by name, so if you have an endpoint configured with
> `put "/customers/:customer_id"` you must call as
> `fetch(CustomerController::UpdateRequest, { customer_id: 123 })`.

> Note: Response specs are only verified in test environment with no
> performance penalty when running in production.

<details open>
  <summary>Minitest example</summary>

```ruby
class API::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "successful registration" do
    response = fetch(RegistrationsController::Request, params: {
      name: "Bilbo Baggins",
      email: "bilbo@shire.com",
      payment_type: "free_trial",
      terms_of_use: true
    })

    assert_equal 200, response.status
    assert_equal "bilbo@shire.com", response.dig(:user, :email)
  end
end
```

</details>

<details open>
  <summary>RSpec example</summary>

```ruby
describe RegistrationsController::Request, type: :request do
  context "when request params are valid" do
    it "successfully registers a new user" do
      response = fetch(described_class, params: {
        name: "Bilbo Baggins",
        email: "bilbo@shire.com",
        payment_type: "free_trial",
        terms_of_use: true
      })

      expect(response.status).to eql(200)
      expect(response.dig(:user, :email)).to eql("bilbo@shire.com")
    end
  end
end
```

</details>

# Publishing documentation

Call `Explicit::Documentation.new` to group, organize and publish the
documentation for your API. The following methods are available:

- `page_title(text)` - Sets the web page title.
- `section(name, &block)` - Adds a section to the navigation menu.
- `add(request)` - Adds a request to the section
- `add(title:, partial:)` - Adds a partial to the section

For example:

```ruby
module MyApp::API::V1
  Documentation = Explicit::Documentation.new do
    page_title "Acme API Docs"

    section "Introduction" do
      add title: "About", partial: "api/v1/introduction/about"
    end

    section "Auth" do
      add RegistrationsController::CreateRequest
      add SessionsController::CreateRequest
      add SessionsController::DestroyRequest
    end

    section "Articles" do
      add ArticlesController::CreateRequest
      add ArticlesController::UpdateRequest
      add ArticlesController::DestroyRequest
    end
  end
end
```

`Explicit::Documentation.new` returns a rails engine that you can mount in
your `config/routes.rb`. For example:

```ruby
Rails.application.routes.draw do
  mount MyApp::API::V1::Documentation => "api/v1/docs"
end
```

## Adding request examples

You can add request examples in two different ways:

1. Manually add an example with `add_example(params:, headers:, response:)`
2. Automatically save examples from tests

### 1. Manually adding examples

In a request, call `add_example(params:, headers:, response:)` after declaring
params and responses. It's important the example comes after params and
responses to make sure it actually follows the spec.

For example:

```ruby
Request = Explicit::Request.new do
  # ... other configs, params and responses

  add_example(
    params: {
      name: "Bilbo baggins",
      email: "bilbo@shire.com",
      payment_type: "free_trial",
      terms_of_use: true
    }
    response: {
      status: 200,
      data: {
        user: {
          id: 15123,
          email: "bilbo@shire.com"
        }
      }
    }
  )
end
```

Request examples are just data, so you can extract and reference them in any
way you like. For example:

```ruby
Request = Explicit::Request.new do
  # ... other configs, params and responses

  add_example MyApp::Examples::REQUEST_1
  add_example MyApp::Examples::REQUEST_2
end
```

### 2. Automatically saving examples from tests

The `fetch` method provided by `Explicit::TestHelper` accepts the option
`add_as_example`. When set to true, the request example is persisted to a local
file. For example:

```ruby
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "successful registration" do
    response = fetch(
      RegistrationsController::Request,
      params: {
        name: "Bilbo Baggins",
        email: "bilbo@shire.com",
        payment_type: "free_trial",
        terms_of_use: true
      },
      add_as_example: true # <-- add this line
    )

    assert_equal 200, response.status
    assert_equal "bilbo@shire.com", response.dig(:user, :email)
  end
end
```

Whenever you wish to refresh the examples file run the test suite with the ENV
`EXPLICIT_PERSIST_EXAMPLES` set. For example
`EXPLICIT_PERSIST_EXAMPLES=true bin/rails test` or
`EXPLICIT_PERSIST_EXAMPLES=true bundle exec rspec`. The examples file is located
at `#{Rails.root}/public/explicit_request_examples.json` by default, but you can
[change it here](#request-examples-file-path).

**Important: be careful not to leak any sensitive data when persisting
examples from tests**

# Specs

### Agreement

```ruby
:agreement
[:agreement, parse: true]
```

A boolean that must always be true. Useful for terms of use or agreement
acceptances. If `parse: true` is specified then the following
values are accepted: `true`, `"true"`, `"on"`, `"1"` and `1`.

### Array

```ruby
[:array, subspec, options = {}]
[:array, :string]
[:array, :integer, empty: false]
```

All items in the array must be valid according to the subspec. If at least one
value is invalid then the array is invalid.

### BigDecimal

```ruby
:bigdecimal
[:bigdecimal, min: 0] # inclusive
[:bigdecimal, max: 100] # inclusive
```

Value must be an integer or a string like `"0.2"` to avoid rounding errors.

[Reference](https://ruby-doc.org/stdlib-3.1.0/libdoc/bigdecimal/rdoc/BigDecimal.html)

### Boolean

```ruby
:boolean
[:boolean, parse: true]
```

If `parse: true` is specified then the following values are converted to `true`:
`"true"`, `"on"`, `"1"` and `1`, and the following values are converted to
`false`: `"false"`, `"off"`, `"0"` and `0`.

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

If you provide a lambda it will execute every time `Request.validate!` is
called.

### Description

```ruby
[:description, markdown_text, subspec]
[:description, "Customer full name", :string]
[:description, "Rating score from 0 (bad) to 5 (good)", :integer]
```

Adds a description to the spec. Descriptions are displayed in documentation
and do not affect validation in any way with. There is no overhead at runtime.
Markdown supported.

### Hash

```ruby
[:hash, keyspec, valuespec, options = {}]
[:hash, :string, :string]
[:hash, :string, :integer]
[:hash, :string, :integer, empty: false]
[:hash, :string, [:array, :date_time_iso8601]]
```

Hashes are key value pairs where all keys must match keyspec and all values must
match valuespec. If you are expecting a hash with a specific set of keys use a
[record](#record) instead.

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
"value" # strings work like a literal specs, so you can use this shorter syntax.
```

A literal value behaves similar to inclusion with a single value. Useful for
matching against multiple specs in [`one_of`](#one-of).

### Nilable

```ruby
[:nilable, subspec]
[:nilable, :string]
[:nilable, [:array, :integer]]
```

Value must either match the subspec or be nil.

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

# Configuration

Add an initializer `config/initializers/explicit.rb` with the following
code, and then make the desired changes to the config.

```ruby
Explicit.configure do |config|
  # change config here...
end
```

### Changing examples file path

```ruby
config.request_examples_file_path = Rails.root.join("public/request_examples.json")
```

### Customizing error messages

Copy the [default error messages translations](https://github.com/luizpvas/explicit/blob/main/config/locales/en.yml)
to your project and make the desired changes.

### Customizing error serialization

First disable the default response:

```ruby
config.rescue_from_invalid_params = false
```

and then add a custom `rescue_from Explicit::Request::InvalidParamsError` to
your base controller. Use the following code as a starting point:

```ruby
class ApplicationController < ActionController::API
  rescue_from Explicit::Request::InvalidParamsError do |err|
    params = Explicit::Spec::Error.translate(err.errors)

    render json: { error: "invalid_params", params: }, status: 422
  end
end
```
