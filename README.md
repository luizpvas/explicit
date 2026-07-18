# Explicit

Explicit is an opinionated set of libraries to extend Rails. It favors
explicit, data-driven definitions over convention and reflection: you declare
what your app expects, and Explicit enforces it at runtime, documents it and
tests it.

| ![Documentation example screenshot](https://raw.githubusercontent.com/luizpvas/explicit/refs/heads/main/assets/webapp_screenshot.png) |
| :-----------------------------------------------------------------------------------------------------------------------------------: |
|             [Click here](https://luizpvas.github.io/explicit_documentation.html) to visit the example documentation page              |

## Installation

Add the following line to your Gemfile and then run `bundle install`:

```ruby
gem "explicit", "~> 0.2"
```

## Features

- **[Requests and documentation](docs/requests.md)** — Define the params,
  headers and responses of your API endpoints next to your controllers.
  Requests are validated at runtime against the documented types,
  documentation is published as a web page straight from the definitions —
  along with an OpenAPI/Swagger schema and an MCP server — and your tests
  verify that responses match the docs.

- **[Types](docs/types.md)** — Types are the foundation of request validation,
  and they can also be used on their own. A type is a data literal describing
  the shape of a value; it validates the input at runtime and coerces it into
  the expected Ruby object, returning a result tagged array.

- **Property based testing** (todo) — Type definitions double as generators:
  produce arbitrary valid — and invalid — inputs from the declared types and
  run your endpoints against hundreds of generated cases instead of a handful
  of hand-picked examples.

- **Mutation testing** (todo) — Mutate the code under test and re-run the test
  suite to check the mutation gets caught. A surviving mutant points to
  behavior your tests don't actually verify.

- **Simulation testing** (todo) — Run long, randomized sequences of requests
  against your app in a controlled, reproducible simulation to surface bugs
  that only appear from the interaction of many operations over time.

- **Generators/factories** (todo) — Generate valid example data and test
  factories directly from type definitions, so fixtures never drift from what
  the API actually accepts.
