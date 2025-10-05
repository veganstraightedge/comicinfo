# ComicInfo Ruby Gem

A Ruby gem that provides an idiomatic interface for reading and writing ComicInfo.xml files, following the official ComicInfo schema specifications from the [Anansi Project](https://github.com/anansi-project/comicinfo).

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4.0-ruby.svg)](https://ruby-lang.org)
[![Gem Version](https://badge.fury.io/rb/comicinfo.svg)](https://badge.fury.io/rb/comicinfo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 📚 **Complete Schema Support**: Full ComicInfo v2.0 schema implementation
- 🔧 **Idiomatic Ruby API**: Clean, Ruby-style interface with proper method naming
- 📁 **Flexible Loading**: Load from file paths or XML strings
- 🌍 **Unicode Support**: Full Unicode and special character handling
- 📖 **Manga Support**: Right-to-left reading direction and manga-specific fields
- ✅ **Comprehensive Validation**: Schema-compliant enum validation and type coercion
- 🚨 **Detailed Error Handling**: Custom exception classes with helpful error messages
- 🧪 **Thoroughly Tested**: 89 test cases covering all functionality and edge cases

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'comicinfo'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install comicinfo

## Usage

### Loading ComicInfo Files

```ruby
require 'comicinfo'

# Load from file path
comic = ComicInfo.load('path/to/ComicInfo.xml')

# Load from XML string
xml_content = File.read('ComicInfo.xml')
comic = ComicInfo.load(xml_content)

# Alternative constructor
comic = ComicInfo::ComicInfo.new(xml_content)
```

### Accessing Comic Information

```ruby
# Basic information
puts comic.title          # "The Amazing Spider-Man"
puts comic.series         # "The Amazing Spider-Man"
puts comic.number         # "1"
puts comic.count          # 600
puts comic.volume         # 3

# Publication details
puts comic.publisher      # "Marvel Comics"
puts comic.year           # 2018
puts comic.month          # 3
puts comic.day            # 15

# Creator information
puts comic.writer         # "Dan Slott, Christos Gage"
puts comic.penciller      # "Ryan Ottley"
puts comic.cover_artist   # "Ryan Ottley"

# Content details
puts comic.page_count     # 20
puts comic.genre          # "Superhero, Action, Adventure"
puts comic.language_iso   # "en-US"
puts comic.format         # "Digital"

# Ratings and reviews
puts comic.age_rating         # "Teen"
puts comic.community_rating   # 4.25
```

### Convenience Methods

```ruby
# Boolean helpers
puts comic.manga?           # false
puts comic.right_to_left?   # false
puts comic.black_and_white? # false

# Page information
puts comic.pages?           # true
puts comic.pages.length     # 12

# Get specific page types
covers = comic.cover_pages
stories = comic.story_pages

# Multi-value fields as arrays
characters = comic.characters_list  # ["Spider-Man", "Peter Parker", ...]
teams = comic.teams_list           # ["Avengers"]
locations = comic.locations_list   # ["New York City", "Manhattan", ...]
```

### Working with Pages

```ruby
comic.pages.each do |page|
  puts "Page #{page.image}: #{page.type}"
  puts "  Double page: #{page.double_page?}" if page.double_page?
  puts "  Bookmark: #{page.bookmark}" if page.bookmarked?
  puts "  Dimensions: #{page.image_width}x#{page.image_height}" if page.dimensions_available?
end

# Page type checks
page = comic.pages.first
puts page.cover?    # true for FrontCover, BackCover, InnerCover
puts page.story?    # true for Story pages
puts page.deleted?  # true for Deleted pages
```

### Manga Support

```ruby
# Load a manga ComicInfo file
manga = ComicInfo.load('manga_comic.xml')

puts manga.title           # "進撃の巨人"
puts manga.series          # "Attack on Titan"
puts manga.manga           # "YesAndRightToLeft"
puts manga.right_to_left?  # true
puts manga.language_iso    # "ja-JP"
puts manga.black_and_white # "Yes"
```

### Error Handling

```ruby
begin
  comic = ComicInfo.load('nonexistent.xml')
rescue ComicInfo::Errors::FileError => e
  puts "File error: #{e.message}"
rescue ComicInfo::Errors::ParseError => e
  puts "Parse error: #{e.message}"
rescue ComicInfo::Errors::InvalidEnumError => e
  puts "Invalid enum: #{e.field} = '#{e.value}', valid: #{e.valid_values}"
rescue ComicInfo::Errors::RangeError => e
  puts "Out of range: #{e.field} = #{e.value}, range: #{e.min}..#{e.max}"
end
```

## Schema Support

This gem fully supports the ComicInfo v2.0 XSD schema with all field types:

### String Fields
- Title, Series, Number, Summary, Notes
- Creator fields (Writer, Penciller, Inker, Colorist, Letterer, CoverArtist, Editor, Translator)
- Publication fields (Publisher, Imprint, Genre, Web, LanguageISO, Format)
- Character/Location fields (Characters, Teams, Locations, MainCharacterOrTeam)
- Story fields (StoryArc, StoryArcNumber, SeriesGroup, ScanInformation, Review)

### Integer Fields
- Count, Volume, AlternateCount, PageCount
- Date fields (Year, Month, Day)

### Enum Fields
- BlackAndWhite: "Unknown", "No", "Yes"
- Manga: "Unknown", "No", "Yes", "YesAndRightToLeft"
- AgeRating: Various ESRB and international ratings

### Decimal Fields
- CommunityRating: 0.0 to 5.0 range with validation

### Complex Fields
- Pages: Array of ComicPageInfo objects with full attribute support

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/comic_info_spec.rb
```

### Code Quality

```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix correctable issues
bundle exec rubocop --autocorrect
```

## Schema Versions

- ✅ **ComicInfo v2.0**: Full support (current)
- 🚧 **ComicInfo v2.1**: Planned
- 🚧 **ComicInfo v1.0**: Planned

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/veganstraightedge/comicinfo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/veganstraightedge/comicinfo/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ComicInfo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/veganstraightedge/comicinfo/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgments

- [Anansi Project](https://github.com/anansi-project/comicinfo) for the ComicInfo schema specification
- [Nokogiri](https://nokogiri.org/) for XML parsing capabilities