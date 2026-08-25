# frozen_string_literal: true

require "test_helper"

# The test that is currently running used to be kept in a class variable shared
# by every thread, so assertions leaked between tests running in parallel.
describe "parallel safety" do
  parallelize_me!

  30.times do |i|
    it "should not hand example #{i} another example's test object" do
      sleep 0.001
      assert_same self, Minitest::ShouldJustWork::Should.current
      i.should == i
    end
  end
end
