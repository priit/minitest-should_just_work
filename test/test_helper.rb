# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/should_just_work"

require "minitest/autorun"

# Most comparisons are exercised from both sides, so the specs need a way to say
# "this one is supposed to fail". Mixed into Minitest::Test rather than into a
# base class, because `describe` generates its own Minitest::Spec subclass.
module ShouldJustWorkAssertions
  # Runs the block and returns the failure it was expected to raise.
  def assert_fails(&)
    assert_raises(Minitest::Assertion, &)
  end
end

Minitest::Test.include ShouldJustWorkAssertions
