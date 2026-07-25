This document describes my ideas on how we're going to implement property based testing.

First of all, I really like the design of Hedgehog with shrink trees. The monadic bind and the composition
between shrink tree, generators and the test itself, alongside do notation, makes it really convenient to
use in haskell. Ruby is another story, though, and we have to be a bit creative in order to offer
the same level of convenience.

The trick for embedding the shrink tree into the generator is by wrapping the test in a stateful context
the tracks `gen` calls by position. Let's take a look at the following example:

```ruby
property "coupon application order does not change final discount" do
  bill = gen(Bill)
  discount_1 = gen(Discount)
  discount_2 = gen(Discount)

  assert_equal bill.apply(discount_1).apply(discount_2), bill.apply(discount_2).apply(discount_1)
end
```

There is a hidden piece underneath this test called the executor responsible for splitting seeds
and managing shrink trees. When running the test for the first time, we don't know which generators
are gonna be used, so we enter as a blank canvas. After running the test one of the two paths is
followed:

* The test passes: re-run with a splitted seed until max-executions is reached, increasing size.
* The test fails: walk down shrink trees to find the minimal counter example.

The goal is to find the smallest and most readable example that reproduces the failure.
Now, in order to walk down shrink trees we have to remember which generators were called
during the test run. This is why `gen` have to be a method in the executor context insted
of a function. Internally, we'll remember the order they were executed, and then provide
shrinked values on subsequent runs, again, based on order.

This raises the question about dependent values. Let's say we have something like:

```
size = gen(:integer)
values = size.map { gen(:string) }
```

Internally, the executer indexes by position + type, so we're able to expand without
conflicts. If fewer generators are touched, no problem. If more, we push to the list.

### The shrinking algorithm

A note on terminology: although the design is inspired by Hedgehog's shrink trees, what we
keep per generator is not really a tree. Each generator holds a committed value plus a lazy
sequence of shrink candidates for it: `next` enumerates candidates for the current committed
value, and `commit` re-derives the candidate sequence from the newly committed value. Walking
candidates-of-candidates this way traverses the same search space as a rose tree without
ever materializing one.

The generators state has this shape:

`{ type_1 => [G0, G1], type_2 => [G0] }`

G stands for generator. It starts empty and gets filled on the first run. If the run is a failure,
we need to shrink one generator at a time. The shrinking algorithm search space should look something like this:

```
loop do
  progress = false

  generators.each do |generator|
    generator.reset

    while (value = generator.next) do
      generator.apply(value)
  
      if test_still_failing?
        generator.commit
        progress = true
      else
        generator.revert
      end
    end
  end

  # The fact we loop again in case of progress means that previous trees will be re-evaluated
  # when next trees are shrinked. This achieves the same behaviour as Hedgehog Applicative's
  # combination for tree A and B, where values are combined in order (not cartesian product).
  return current_values unless progress
end
```

### Generators

We will provide low level primitives and convenient wrappers for both Explicit::Type with
constraints (see docs/types.md) and Rails models. A generator is a class that with the
following interface:

```
class Generator
  # Size describes how large the magnitude of the range is. The value is 0 to 100, where 0 means
  # small as possible and 100 full range available - whatever that means for the generator.
  # Seed is the RNG. Same size + seed should produce the same value.
  def initialize(size, seed)

  # Restes to the last committed value (not the original draw)
  def reset

  def next
  def apply(value)

  def commit
  def revert

  # Must be implemented by child class
  def draw = raise NotImplementedError
end
```

Let's talk about primitive generators:

* Integer: accepts a range and origin as argument that is fully used when size is 100.
  Below 100, the maximum distance from origin scales proportionally with size. Shrinking
  binary-searches toward the origin: try the origin itself first, then midpoints between
  the origin and the current value.
* Float: accepts a range and origin as argument that is fully used when size is 100.
* List: they could be defined as a combination of int for length plus the subgenerator,
  but in order to make shrinking more effective, we can implement a custom primitive that
  is smarter in how it manipulates its items.
* String: strings are also special, specially because of regexs. This is not something we
  need to support on v1, but at some point we'll need to build a regex parser in order to
  generate strings complying to the format.

Those are the only primitives we need. We can derive other generators using them.

### Seeds

Ruby's Random is not splittable like Haskell's SplitMix, and we don't want to add a
dependency, so we implement SplitMix64 ourselves (the same algorithm used by Hedgehog and
Java's SplittableRandom). It's ~20 lines of pure 64-bit integer arithmetic: an add-gamma
step plus two xor-shift-multiply mixes, where split derives a new seed and a new odd gamma
from the current state.

Splitting matters here (vs. deriving seeds sequentially from a single shared Random)
because each `gen` position gets its own split seed. A shrink run that takes a different
code path and calls more or fewer generators doesn't perturb the values of unrelated
positions, which keeps the "push to the list" expansion case stable.

The master seed is printed on failure and can be set via `EXPLICIT_SEED` to replay a
failing run deterministically.

### Failure reporting

After shrinking finishes, we re-raise the final shrunk run's `Minitest::Assertion` with a
prefixed message instead of building a report from scratch. The user keeps the real
assertion output — including Minitest's Expected/Actual diff, often the most informative
line — and it integrates with every reporter and CI formatter for free. Example:

```
Property failed after 13 runs and 47 shrink steps.

Minimal counterexample:
  gen(:integer)  [0] = 0
  gen(:integer)  [1] = -1

Reproduce with: EXPLICIT_SEED=3f9a2c bin/rails test test/models/bill_test.rb

--- original failure ---
Expected: 100
  Actual: 99
```

The ingredients, in order of usefulness:

1. The minimal counterexample, one line per `gen` call in call order, showing the type and
   args the user passed. Position + type is the closest we can get to naming the variable.
   Values printed with `inspect`.
2. The assertion message from the minimal run (not the original run) — it describes the
   failure at the values the user will actually debug with.
3. A copy-pasteable reproduction command with the seed.
4. Run/shrink counts — a trust signal that the example really is minimal.

We deliberately do not include the original pre-shrink values: nobody debugs with the
unshrunk example and it doubles the noise. Could sit behind a verbose flag later.

### Configuration

* Max runs: 100 by default, configurable via `Explicit.configure { _1.property_max_runs = ... }`
  with `EXPLICIT_PROPERTY_MAX_RUNS` taking precedence — same shape as
  `request_examples_persistance_enabled?`. Kept flat on `Explicit::Configuration` to match
  the current style; revisit nesting if we accumulate 3+ property settings.
* `EXPLICIT_SEED`: env only, no settings counterpart — it's a reproduction tool printed by
  the failure report. When set, the master seed replays the same sequence of values.

### Code design

The surface area to use this library should be small from the user's perspective.
People are used to the `test` in Minitest. Let's introduce a new function named
`example`, which is an alias to `test` (to have contrast with property) and a new
function `property` with the same signature as test. We already have `Explicit::TestHelper`
defined (it includes `Explicit::Request::TestHelper`), so the new property module gets
included there as well.

* `Explicit::Testing::Property::Seed`: SplitMix64 implementation (see Seeds section).
* `Explicit::Testing::Property::Generator`: base class that implements reset, apply
  commit and revert.
* `Explicit::Testing::Property::Generator::Integer`: inherits from base class and
  implements draw.
* `Explicit::Testing::Property::Generator::Float`: inherits from base class and
  implements draw.
* `Explicit::Testing::Property::Executor`: stateful wrapper that keeps track of
  generators by type+position. Handles execution N times increasing size on each
  attempt. Also implements shrinking logic in case of failures.
* `Explicit::Testing::Property::TestHelper`: entry module that needs to be included
  from `ActiveSupport::TestCase`. This module defines the `property` function and
  `gen` function. The property function needs to be convert to a regular test, but
  the callback provided by the user can't be called directly. Instead, wrap in
  another callback that instantiates an executor and sets an instance var with so
  `gen` calls are tracked. The user-provided callback is passed to the executor
  as an argument. Reference code for Minitest:

  ```
  def property(name, **opts, &block)
    test(name) do
      @_property_executor = Explicit::Testing::Property::Executor.new
      @_property_executor.run { instance_exec(&block) }
    ensure
      @_property_executor = nil
    end
  end

  def gen(type, **opts)
    if @_property_executor.nil?
      raise "can only be called inside a property test"
    end

    @_property_executor.gen(type, **opts)
  end
  ```

  Note that `property` must be a class method — Minitest's `test` is a class-level
  macro — while `gen` is an instance method, so the concern defines them in separate
  blocks (`class_methods do` for `property`).

### POC scope

The first iteration is integer-only:

* `gen(:integer, ...)` takes the same kwargs as `Explicit::Type::Integer`
  (min/max/negative/positive), plus a generator-specific `origin:` for shrinking.
  The generator derives its range from those constraints.
* Minitest only.
* Float, list and string generators, plus Rails model generators, come later.

