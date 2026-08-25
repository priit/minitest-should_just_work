# Minitest::ShouldJustWork

[![CI](https://github.com/priit/minitest-should_just_work/actions/workflows/ci.yml/badge.svg)](https://github.com/priit/minitest-should_just_work/actions/workflows/ci.yml)

Classic RSpec-like `.should` / `.should_not` comparisons for Minitest.

```ruby
book.title.should == "Revolution"
```

That is the whole idea. The gem monkey-patches Object so that comparison
operators after `.should` turn into plain Minitest assertions.

(*Ouch! Monkey patch?* Yes! But it only defines `Object#should` and
 `#should_not`.)

Requires Ruby >= 3.1. Tested against Minitest 5 and Minitest 6.

## Installation

Add it to your application's Gemfile:

``` ruby
group :test do
  gem 'minitest-spec-rails'
  gem 'minitest-should_just_work'
end
```

    $ bundle

## Usage

``` ruby
require 'minitest/autorun'
require 'minitest/should_just_work'

describe "Books" do
  it "should work" do
    book = Book.new title: "Revolution"

    book.title.should == "Revolution"
  end
end
```

### Comparisons

| Minitest::ShouldJustWork          | [Minitest::Assertions]           |
|-----------------------------------|----------------------------------|
| `x.should == y`                   | `assert_equal y, x`              |
| `x.should == nil`                 | `assert_nil x`                   |
| `x.should != y`                   | `refute_equal y, x`              |
| `x.should != nil`                 | `refute_nil x`                   |
| `x.should =~ /y/`                 | `assert_match /y/, x`            |
| `x.should > y`                    | `assert_operator x, :>, y`       |
| `x.should < y`                    | `assert_operator x, :<, y`       |
| `x.should >= y`                   | `assert_operator x, :>=, y`      |
| `x.should <= y`                   | `assert_operator x, :<=, y`      |

Note that `x.should == nil` asserts nil rather than equality with nil. Minitest 5
deprecates `assert_equal nil, x` and Minitest 6 fails it outright, so this is the
only spelling that can work.

### Negating

Use `should_not`, or `should.not`, to turn any comparison into its `refute_`:

```ruby
  obj.should_not == 3                # => refute_equal 3, obj
  obj.should_not =~ /regex/          # => refute_match /regex/, obj
  obj.should_not == nil              # => refute_nil obj
```

### Exceptions and throws

```ruby
  should.raise ZeroDivisionError do
    2 / 0
  end

  should_not.raise ZeroDivisionError do
    2 / 1
  end

  should.throw(:done) { throw :done }
  should_not.throw(:done) { keep_going }
```

`should.raise` with no argument catches `StandardError`.

[Minitest::Assertions]: https://github.com/minitest/minitest/blob/master/lib/minitest/assertions.rb

## RuboCop

`obj.should == 2` is a statement whose value is discarded, and `obj.should == nil`
compares against nil on purpose. Three cops object to exactly that, so switch
them off for your tests:

``` yaml
Lint/Void:
  Exclude:
    - test/**/*
Style/NilComparison:
  Exclude:
    - test/**/*
Style/NonNilCheck:
  Exclude:
    - test/**/*
```

Ruby's own `-w` will also report "useless use of == in void context" for every
line, so leave warnings off for your test task.

## Development

    $ bin/setup
    $ bundle exec rake        # tests and RuboCop

To run the suite against a particular Minitest line:

    $ MINITEST_VERSION="~> 5.0" bundle install && MINITEST_VERSION="~> 5.0" bundle exec rake test

## Acknowledgements & licensing

Inspired by the minitest-should_syntax gem.

(c) 2022-2026 Priit Tark, MIT license
(c) 2013 Rico Sta. Cruz, MIT license
