# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in minitest-should_just_work.gemspec
gemspec

# CI pins this to test against every supported Minitest line.
minitest_version = ENV.fetch("MINITEST_VERSION", nil)
gem "minitest", minitest_version if minitest_version

gem "rake", "~> 13.0"
gem "rubocop", "~> 1.21"
