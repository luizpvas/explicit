# Explicit

Explicit is a validation and documentation library for REST APIs that enforces
documented types at runtime.

| ![Documentation example screenshot](https://raw.githubusercontent.com/luizpvas/explicit/refs/heads/main/assets/webapp_screenshot.png) |
| :-----------------------------------------------------------------------------------------------------------------------------------: |
|             [Click here](https://luizpvas.github.io/explicit_documentation.html) to visit the example documentation page              |

1. [Installation](#installation)
2. [Defining requests](#defining-requests)
3. [Reusing types](#reusing-types)
4. [Reusing requests](#reusing-requests)
5. [Writing tests](#writing-tests)
6. [Publishing documentation](#publishing-documentation)
   - [Adding request examples](#adding-request-examples)
7. [MCP](#mcp)
   - [Tool configuration](#tool-configuration)
   - [Security](#security-and-authorization)
8. Types
   - [Agreement](#agreement)
   - [Any](#any)
   - [Array](#array)
   - [BigDecimal](#big_decimal)
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
9. [Configuration](#configuration)
   - [Changing examples file path](#changing-examples-file-path)
   - [Customizing error messages](#customizing-error-messages)
   - [Customizing error serialization](#customizing-error-serialization)
   - [Raise on invalid example](#raise-on-invalid-example)

# Installation

Add the following line to your Gemfile and then run `bundle install`:

```ruby
gem "explicit", "~> 0.2"
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
- `header(name, type, options = {})` - Adds a type to the request header.
  - The following options are available:
    - `auth: :bearer` - Sets the authentication to [bearer](https://swagger.io/docs/specification/v3_0/authentication/bearer-authentication/).
    - `auth: :basic` - Sets the authentication to [basic](https://swagger.io/docs/specification/v3_0/authentication/basic-authentication/).
- `param(name, type, options = {})` - Adds a type to the request param.
  It works for params in the request body, query string and path params.
  - The following options are available:
    - `optional: true` - Makes the param nilable.
    - `default: value` - Sets a default value to the param, which makes it optional.
    - `description: "text"` - Adds a documentation to the param. Markdown supported.
- `response(status, type)` - Adds a response type. You can add multiple
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

    description <<~MD
    Attempts to register a new user in the system. If `payment_type` is not
    specified a trial period of 30 days is started.
    MD

    param :name, [:string, empty: false]
    param :email, [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true]
    param :payment_type, [:enum, ["free_trial", "credit_card"]], default: "free_trial"
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

# Reusing types

Types are just data. You can share types the same way you reuse constants or
configs in your app. For example:

```ruby
module MyApp::Type
  UUID = [:string, format: /^\h{8}-(\h{4}-){3}\h{12}$/].freeze
  EMAIL = [:string, format: URI::MailTo::EMAIL_REGEXP, strip: true].freeze

  ADDRESS = {
    country_name: [:string, empty: false],
    zipcode: [:string, format: /\d{6}-\d{3}/]
  }.freeze
end

# ... and then reference the shared types when needed
Request = Explicit::Request.new do
  param :customer_uuid, MyApp::Type::UUID
  param :email, MyApp::Type::EMAIL
  param :address, MyApp::Type::ADDRESS
end
```

# Reusing requests

Sometimes it is useful to share a group of params, headers or responses between
requests. You can achieve this by instantiating requests from an existing
request instead of `Explicit::Request`. For example:

```ruby
AuthenticatedRequest = Explicit::Request.new do
  base_url "https://my-app.com"
  base_path "/api/v1"

  header "Authorization", [:string, format: /Bearer [a-zA-Z0-9]{20}/], auth: :bearer

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
expected and that it responds with a valid response according to the docs.

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
assertions against the response. If the response is invalid the test fails with
`Explicit::Request::InvalidResponseError`.

The response object has a `status`, an integer value for the http status, and
`data`, a hash with the response data. It also provides `dig` for a
slighly shorter syntax when accessing nested attributes.

> Path params are matched by name, so if you have an endpoint configured with
> `put "/customers/:customer_id"` you must call as
> `fetch(CustomerController::UpdateRequest, { customer_id: 123 })`.

> Note: Response types are only verified in test environment with no
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
- `company_logo_url(url)` - Shows the company logo in the navigation menu.
  The url can also be a lambda that returns the url, useful for referencing
  assets at runtime.
- `favicon_url(url)` - Adds a favicon to the web page.
- `version(semver)` - Sets the version of the API. Default: "1.0"
- `section(name, &block)` - Adds a section to the navigation menu.
- `add(request)` - Adds a request to the section
- `add(title:, partial:)` - Adds a partial to the section

For example:

```ruby
module MyApp::API::V1
  Documentation = Explicit::Documentation.new do
    page_title "Acme API Docs"
    company_logo_url "https://my-app.com/logo.png"
    favicon_url "https://my-app.com/favicon.ico"
    version "1.0.5"

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
responses to make sure it actually follows the type definition.

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
`UPDATE_REQUEST_EXAMPLES` set. For example
`UPDATE_REQUEST_EXAMPLES=true bin/rails test` or
`UPDATE_REQUEST_EXAMPLES=true bundle exec rspec`. The file is located at
`#{Rails.root}/public/explicit_request_examples.json` by default, but you can
[change it here](#request-examples-file-path).

**Important: be careful not to leak any sensitive data when persisting
examples from tests**

# MCP

You can expose your API endpoints as tools for external systems, like AI agents,
by mounting an MCP server. The MCP server acts as a proxy receiving tool calls
and forwarding them to your existing REST API controllers. In other words,
your controllers remain the source of truth and the MCP server simply provides a
tool-compatible interface.

To build an MCP server, instantiate `::Explicit::MCPServer` and add the requests
you wish to expose. It is important that the requests are compatible with MCP
tool format spec, otherwise an error is raised. All params should be primitives
such as `:string`, `:integer` or `:boolean`.

The following methods are available:

- `name(str)` - Sets the name of the MCP Server which is displayed in the MCP
  client.
- `version(str)` - Sets the version of the MCP server which is displayed in the
  MCP client
- `add(request)` - Exposes a request as a tool in the MCP server.

For example:

```ruby
module MyApp::API::V1
  MCPServer = Explicit::MCPServer.new do
    name "My app"
    version "1.0.0"

    add ArticlesController::CreateRequest
    add ArticlesController::UpdateRequest
    add ArticlesController::DestroyRequest

    def authorize(**)
      true
    end
  end
end
```

Then, mount the MCP Server in `routes.rb`:

```ruby
Rails.application.routes.draw do
  mount MyApp::API::V1::MCPServer => "/api/v1/mcp"
end
```

If your app boots with no errors, it means you have a working MCP server that
you can connect from any MCP client (Claude Desktop, Cursor Agent, etc.)

### Tool configuration

The following methods are available in `Explicit::Request` to configure the MCP
tool. They're all optional and the MCP server still works correctly using the
request's default title, description and params.

- `mcp_tool_name(name)` - Sets the unique identifier for the tool. Should be a
  string with only ASCII letters, numbers and underscore. By default it is set
  to a normalized version of the route's path.
- `mcp_tool_description(description)` - Sets the description of the tool.
  Markdown supported. By default it is set to the request description.
- `mcp_tool_title(title)` - Sets the human readable name for the tool. By
  default it is set to the request's title.
- `mcp_tool_read_only_hint(true/false)` - If true, the tool does not modify its
  environment.
- `mcp_tool_destructive_hint(true/false)` - If true, the tool may perform destructive
  updates.
- `mcp_tool_idempotent_hint(true/false)` - If true, repeated calls with same args
  have no additional effect.
- `mcp_tool_open_world_hint(true/false)` - If true, tool interacts with external
  entities.

For example:

```ruby
Request = Explicit::Request.new do
  # ... other request config

  mcp_tool_name "get_article_by_id"
  mcp_tool_title "Get article by id"
  mcp_tool_read_only_hint true
  mcp_tool_destructive_hint false
  mcp_tool_idempotent_hint true
  mcp_tool_open_world_hint false

  mcp_tool_description <<~TEXT
    Finds the article by the specified id and returns the title, body and
    published_at date.
  TEXT
end
```

### Security

There are two considerations for securing your MCP server:

1. **Authorize the MCP tool call**
   You should authorize the action based on a unique attribute present in the
   request's params or headers. For example, you should share a URL
   similar to this one to your customers:
   `https://myapp.com/api/v1/mcp?key=d17c08d5-968c-497f-8db2-ec958d45b447`.
   Then, in the `authorize` method, you'd use the `key` to find the
   user/customer/account.
2. **Authenticate the REST API**
   Your API probably has an authentication mechanism that is different from the
   MCP server, such as bearer tokens specified in request headers. To
   authenticate the API you can either 1) use `proxy_with(headers:)` or 2)
   share the current user using `ActiveSupport::CurrentAttributes`.

To secure your MCPServer you must implement the method `authorize` inside
`Explicit::MCPServer`. This method will be invoked for all requests received
by the MCP server. This method receives `params`, which are the key-value pairs
present in the request's query string, and `headers`, which are the HTTP headers
present in the request's headers. If you return `false` then the request
will be rejected immediatly without hitting your API controllers.

```ruby
module MyApp::API::V1
  MCPServer = Explicit::MCPServer.new do
    def authorize(params:, headers:, **)
      user = ::User.find_by(api_key: params[:key])
      return false if user.blank?

      # 1) proxy the request to controllers with headers
      proxy_with headers: { "Authorization" => "Bearer #{user.api_key}" }

      # 2) or share the user with controllers using ActiveSupport::CurrentAttributes
      Current.user = user
    end
  end
end
```

# Types

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
and do not affect validation in any way with. There is no overhead at runtime.
Markdown supported.

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
    render json: { error: "invalid_params", params: err.errors }, status: 422
  end
end
```

### Raise on invalid example

```ruby
config.raise_on_invalid_example = true # default is false
config.raise_on_invalid_example = ::Rails.env.development? # recommended
```
