# frozen_string_literal: true

require_relative "lib/minitest/should_just_work/version"

Gem::Specification.new do |spec|
  spec.name = "minitest-should_just_work"
  spec.version = Minitest::ShouldJustWork::VERSION
  spec.authors = ["Rico Sta. Cruz", "Priit Tark"]
  spec.email = ["priit@domify.io"]

  spec.summary = "RSpec-like .should/.should_not syntax for MiniTest."
  spec.description = "Enables classic .should/.should_not syntax similar to classic RSpec on your MiniTest tests."
  spec.homepage = "http://github.com/priit/minitest-should_just_work"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = spec.homepage

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "http://github.com/priit/minitest-should_just_work/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "rake"
end
