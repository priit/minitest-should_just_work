# frozen_string_literal: true

require "test_helper"

describe "Minitest::ShouldJustWork" do
  it "should have a version number" do
    refute_nil Minitest::ShouldJustWork::VERSION
  end

  describe "==" do
    it "should assert equality" do
      1.should == 1
      "a".should == "a"
    end

    it "should fail when the values differ" do
      assert_fails { 1.should == 2 }
    end
  end

  describe "!=" do
    it "should refute equality" do
      1.should != 2
    end

    it "should fail when the values are equal" do
      assert_fails { 1.should != 1 }
    end
  end

  # Minitest 6 refuses assert_equal nil outright, and Minitest 5 deprecates it,
  # so comparing against nil has to mean assert_nil.
  describe "comparing against nil" do
    it "should assert nil" do
      nil.should == nil
    end

    it "should fail when the value is not nil" do
      assert_fails { 1.should == nil }
    end

    it "should refute nil with !=" do
      1.should != nil
    end

    it "should fail when != nil is given nil" do
      assert_fails { nil.should != nil }
    end

    it "should refute nil with should_not" do
      1.should_not == nil
    end

    it "should fail when should_not == nil is given nil" do
      assert_fails { nil.should_not == nil }
    end
  end

  describe "=~" do
    it "should assert a regexp match" do
      "hello".should =~ /ell/
    end

    it "should fail when the regexp does not match" do
      assert_fails { "hello".should =~ /xyz/ }
    end
  end

  describe "comparison operators" do
    it "should assert greater than, less than and their inclusive forms" do
      2.should > 1
      1.should < 2
      2.should >= 2
      2.should <= 2
    end

    it "should fail when the comparison does not hold" do
      assert_fails { 1.should > 2 }
      assert_fails { 2.should < 1 }
      assert_fails { 1.should >= 2 }
      assert_fails { 2.should <= 1 }
    end
  end

  describe "should_not" do
    it "should negate every operator" do
      1.should_not == 2
      1.should_not != 1
      "a".should_not =~ /b/
      1.should_not > 2
      2.should_not < 1
      1.should_not >= 2
      2.should_not <= 1
    end

    it "should fail when the negated comparison holds" do
      assert_fails { 1.should_not == 1 }
      assert_fails { "a".should_not =~ /a/ }
      assert_fails { 2.should_not > 1 }
    end

    it "should also be spelled should.not" do
      1.should.not == 2
      assert_fails { 1.should.not == 1 }
    end
  end

  describe "should.raise" do
    it "should assert that the block raises" do
      should.raise(ArgumentError) { raise ArgumentError }
    end

    it "should default to StandardError" do
      should.raise { raise "boom" }
    end

    it "should fail when nothing is raised" do
      assert_fails { should.raise(ArgumentError) { nil } }
    end
  end

  describe "should_not.raise" do
    it "should pass when the block is quiet" do
      should_not.raise(ArgumentError) { nil }
      should_not.raise { 1 + 1 }
    end

    it "should fail when the block raises" do
      assert_fails { should_not.raise(ArgumentError) { raise ArgumentError } }
    end

    it "should let unrelated exceptions through" do
      assert_raises(TypeError) { should_not.raise(ArgumentError) { raise TypeError } }
    end
  end

  describe "should.throw" do
    it "should assert that the block throws" do
      should.throw(:done) { throw :done }
    end

    it "should fail when nothing is thrown" do
      assert_fails { should.throw(:done) { nil } }
    end
  end

  describe "should_not.throw" do
    it "should pass when nothing is thrown" do
      should_not.throw(:done) { nil }
    end

    it "should fail when the block throws" do
      assert_fails { should_not.throw(:done) { throw :done } }
    end

    it "should require a symbol to watch for" do
      assert_raises(Minitest::ShouldJustWork::Error) { should_not.throw { nil } }
    end
  end

  # The chained matcher DSL was dropped in 1.0. Object answers to some of those
  # names itself, so the old spelling has to raise rather than quietly return a
  # boolean and pass without asserting anything.
  describe "the syntax removed in 1.0" do
    it "should raise for the chained matcher DSL" do
      assert_raises(NoMethodError) { 1.should.be }
      assert_raises(NoMethodError) { [].should.be.empty }
      assert_raises(NoMethodError) { 1.should.equal(1) }
      assert_raises(NoMethodError) { [1].should.include(1) }
      assert_raises(NoMethodError) { should.satisfy { true } }
    end

    it "should raise for predicates instead of passing silently" do
      assert_raises(NoMethodError) { nil.should.nil? }
      assert_raises(NoMethodError) { 1.should.respond_to?(:to_s) }
      assert_raises(NoMethodError) { "x".should.frozen? }
      assert_raises(NoMethodError) { 1.should.is_a?(Integer) }
      assert_raises(NoMethodError) { [].should.empty? }
    end
  end

  describe "outside a running test" do
    it "should raise a clear error" do
      Minitest::ShouldJustWork::Should.init nil
      assert_raises(Minitest::ShouldJustWork::Error) { 1.should == 1 }
    ensure
      Minitest::ShouldJustWork::Should.init self
    end
  end
end
