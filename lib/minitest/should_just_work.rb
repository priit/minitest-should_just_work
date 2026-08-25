# frozen_string_literal: true

require "minitest"

require_relative "should_just_work/version"

# Minitest's own namespace, reopened to hold the DSL and to teach Minitest::Test
# about it.
module Minitest
  # Rspec-like operator assertions for Minitest.
  #
  # == Usage
  #
  #   obj.should == 2
  #   obj.should != 3
  #   obj.should == nil      # asserts nil, not equality with nil
  #   obj.should =~ /regex/
  #   obj.should > 1
  #
  #   # Negate with should_not, or with .not:
  #   obj.should_not == 3
  #   obj.should.not == 3
  #
  #   # Errors and throws:
  #   should.raise(ArgumentError) { boom }
  #   should_not.throw(:x) { quiet }
  #
  #   # Messages:
  #   otherwise "Age must be set properly"
  #   age.should == 18
  #
  module ShouldJustWork
    # Raised when the DSL is used outside of a running Minitest test.
    class Error < StandardError; end

    # The object returned by Object#should. It remembers what .should was called
    # on and forwards the comparison to the test that is currently running.
    class Should
      # The chained matcher DSL (`should.be.empty`, `should.be.nil?`) was dropped
      # in 1.0. Object answers to some of those names itself, so without this the
      # old spelling would quietly return a boolean and pass without asserting
      # anything. Undefined, they raise instead.
      %i[nil? frozen? respond_to? is_a? kind_of? instance_of? eql? equal?].each do |name|
        undef_method name if method_defined?(name)
      end

      # Remembers the test that is currently running. Minitest can run tests in
      # parallel threads, so the test is kept in a thread variable rather than in
      # a class variable shared by every thread.
      def self.init(test) # :nodoc:
        ::Thread.current.thread_variable_set(:minitest_should_just_work_test, test)
      end

      def self.current # :nodoc:
        ::Thread.current.thread_variable_get(:minitest_should_just_work_test)
      end

      def initialize(left)
        @left = left
        @neg = false

        pending = test.msg
        return unless pending

        test.msg = nil
      end

      # `should == nil` means assert_nil rather than assert_equal, which Minitest
      # 6 refuses outright and Minitest 5 deprecates.
      def ==(other)
        other.nil? ? assert_or_refute(:nil, left) : assert_or_refute(:equal, other, left)
      end

      def !=(other)
        other.nil? ? refute_or_assert(:nil, left) : refute_or_assert(:equal, other, left)
      end

      def =~(other) = assert_or_refute(:match, other, left)
      def >(other) = assert_or_refute(:operator, left, :>, other)
      def <(other) = assert_or_refute(:operator, left, :<, other)
      def >=(other) = assert_or_refute(:operator, left, :>=, other)
      def <=(other) = assert_or_refute(:operator, left, :<=, other)

      # Negates the comparison that follows. `should_not` is the shorthand.
      def not
        @neg = true
        self
      end

      # should.throw(:sym) { ... } and should_not.throw(:sym) { ... }
      def throw(sym = nil, &blk)
        return test.send(:assert_throws, sym, msg, &blk) if positive?

        ::Kernel.raise(Error, "should_not.throw needs a symbol to watch for") if sym.nil?

        thrown = true
        ::Kernel.catch(sym) do
          blk.call
          thrown = false
        end
        test.send(:refute, thrown, [msg, "Expected the block not to throw #{sym.inspect}"].compact.join("\n"))
      end

      # should.raise(SomeError) { ... } and should_not.raise(SomeError) { ... }
      def raise(exception = ::StandardError, &)
        return test.send(:assert_raises, *[exception, msg].compact, &) if positive?

        raised = capture(exception, &)
        test.send(:refute, raised,
                  [msg, "Expected the block not to raise #{exception}, got #{raised.inspect}"].compact.join("\n"))
      end

      private

      attr_reader :left, :msg

      def test
        Should.current ||
          ::Kernel.raise(Error, "#should can only be used inside a running Minitest test")
      end

      def positive? = !@neg
      def negative? = @neg

      def assert_or_refute(what, *args)
        args << msg if msg
        test.send(positive? ? :"assert_#{what}" : :"refute_#{what}", *args)
      end

      def refute_or_assert(what, *args)
        args << msg if msg
        test.send(negative? ? :"assert_#{what}" : :"refute_#{what}", *args)
      end

      def capture(exception)
        yield
        nil
      rescue exception => e
        e
      end

      def method_missing(name, ...)
        ::Kernel.raise(NoMethodError,
                       "undefined matcher '#{name}'. minitest-should_just_work supports the operators " \
                       "==, !=, =~, <, >, <= and >=, plus should.raise and should.throw")
      end

      def respond_to_missing?(_name, _include_private = false) = false
    end

    # Prepended to Minitest::Test so every test hands itself to ShouldJustWork
    # before it runs, and so tests gain the #msg and #otherwise helpers.
    module TestHelpers
      def before_setup
        Should.init self
        super
      end

      # Reads the failure message waiting to be attached to the next comparison,
      # or sets it when given one.
      def msg(string = nil)
        self.msg = string if string
        @msg
      end

      attr_writer :msg

      # Reads better than #msg in front of an assertion.
      def otherwise(message) = msg(message)
    end
  end

  Test.prepend ShouldJustWork::TestHelpers
end

# The one monkey patch this gem makes: every object gains #should and #should_not.
class Object
  def should = Minitest::ShouldJustWork::Should.new(self)
  def should_not = should.not
end
