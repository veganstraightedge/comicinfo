# frozen_string_literal: true

require_relative "lib/comicinfo/version"

Gem::Specification.new do |spec|
  spec.name = "comicinfo"
  spec.version = Comicinfo::VERSION
  spec.authors = ["Shane Becker"]
  spec.email = ["veganstraightedge@gmail.com"]

  spec.summary = "Ruby interface for working with ComicInfo.xml files"
  spec.description = "A Ruby gem that provides an idiomatic interface for reading and writing ComicInfo.xml files, following the official ComicInfo schema specifications from the Anansi Project."
  spec.homepage = "https://github.com/veganstraightedge/comicinfo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/veganstraightedge/comicinfo"
  spec.metadata["changelog_uri"] = "https://github.com/veganstraightedge/comicinfo/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "nokogiri", ">= 1.18.10"

  # Development dependencies
  spec.add_development_dependency "rspec", ">= 3.13.1"
  spec.add_development_dependency "rubocop", ">= 1.81.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
