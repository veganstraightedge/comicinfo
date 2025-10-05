require_relative 'lib/comicinfo/version'

Gem::Specification.new do |spec|
  spec.name    = 'comicinfo'
  spec.version = ComicInfo::VERSION
  spec.authors = ['Shane Becker']
  spec.email   = ['veganstraightedge@gmail.com']

  spec.summary     = 'Ruby interface for working with ComicInfo.xml files'
  spec.description = <<~DESCRIPTION
    An idiomatic Ruby interface for reading and writing ComicInfo.xml files,
    following the official ComicInfo schema specifications from the Anansi Project
  DESCRIPTION

  spec.homepage = 'https://github.com/veganstraightedge/comicinfo'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.4.6'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/veganstraightedge/comicinfo'
  spec.metadata['changelog_uri']     = 'https://github.com/veganstraightedge/comicinfo/blob/main/CHANGELOG.md'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename __FILE__

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |file|
      ignored_files = %w[
        bin/
        Gemfile
        .gitignore
        .rspec
        spec/
        .github/
        .rubocop.yml
        .rubocop_todo.yml
      ]

      (file == gemspec) || file.start_with?(*ignored_files)
    end
  end

  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.bindir        = 'exe'

  # Runtime dependencies
  spec.add_dependency 'nokogiri', '>= 1.18.10'
end
