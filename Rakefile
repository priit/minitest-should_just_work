# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
  # The whole point of this gem is that `obj.should == 2` is a statement, which
  # Ruby's -w flags as a useless use of == in void context on every single line.
  t.warning = false
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
