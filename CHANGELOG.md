## [Unreleased]

## [1.0.0] - 2026-08-25

This release narrows the gem to the operator syntax it was really used for, and
fixes everything that was broken in the part that stays.

### Removed

- The chained matcher DSL. `should.be`, `.a`, `.an`, `.nil`, `.empty`,
  `.include`, `.same`, `.instance_of`, `.kind_of`, `.respond_to`, `.close`,
  `.in_epsilon`, `.satisfy`, `.true`, `.false`, `.match` and `.equal` are gone,
  along with the pass-through predicates (`should.be.empty?`) and the custom
  matcher hook (`ShouldJustWork.add` / `Should.add`).

  Use plain Minitest assertions for those: `assert_empty x`, `assert_includes x, y`,
  `assert_instance_of Y, x`, and so on. The old spellings raise `NoMethodError`
  with a message naming what is supported, rather than silently passing.

  This removes all of the metaprogramming the gem used to need: the matcher
  proxy no longer defines `method_missing` matchers and no longer undefines the
  methods it inherits from `Object`.

### Fixed

- Works on Minitest 6. The gem required the removed `minitest/unit`, and patched
  the removed `MiniTest` constant alias, so on Minitest 6 it failed to load at
  all. It now requires `minitest` and uses the `Minitest` namespace, and is
  tested against both Minitest 5 and 6.
- `x.should == nil` now asserts nil. It used to become `assert_equal nil, x`,
  which Minitest 5 deprecates and Minitest 6 fails outright.
- `should.raise(SomeError) { ... }` passed a `nil` message through to
  `assert_raises`, which Minitest 6 rejects with a `TypeError`.
- The test currently running is kept in a thread variable instead of a class
  variable, so assertions no longer leak between tests running in parallel
  threads.
- Using `should` outside of a running test now raises a clear
  `Minitest::ShouldJustWork::Error` instead of failing obscurely.

### Added

- `should_not.raise(SomeError) { ... }` and `should_not.throw(:sym) { ... }`,
  which previously printed a warning and asserted nothing.
- A real test suite, and CI across Ruby 3.1-4.0 and Minitest 5 and 6.

### Changed

- Requires Ruby >= 3.1 (was 2.6, which has been end-of-life since 2022).
- The `minitest` dependency is constrained to `>= 5.0, < 7`.

## [0.1.0] - 2022-12-21

- Initial release
