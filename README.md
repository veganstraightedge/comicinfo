# ComicInfo Ruby Gem

A Ruby gem that provides an idiomatic interface for reading and writing ComicInfo.xml files,
following the official ComicInfo schema specifications from the
[Anansi Project](https://github.com/anansi-project/comicinfo).

![Ruby](https://img.shields.io/badge/ruby-%3E%3D%204.0.9-ruby.svg)
![Gem Version](https://badge.fury.io/rb/comicinfo.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Features

- 📚 **Complete Schema Support**: Full ComicInfo v2.0 schema implementation
- 🔧 **Idiomatic Ruby API**: Ruby-style interface with proper method naming
- 📁 **Flexible Loading**: Load from file paths or XML strings
- 🌍 **Unicode Support**: Full Unicode and special character handling
- 📖 **Manga Support**: Right-to-left reading direction and manga-specific fields
- ✅ **Comprehensive Validation**: Schema-compliant enum validation and type coercion
- 🚨 **Detailed Error Handling**: Custom exception classes with helpful error messages
- 📊 **Export Support**: JSON, YAML, and XML serialization with hash representation
- ✍️ **XML Generation**: Complete ComicInfo.xml writing with round-trip consistency

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'comicinfo'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install comicinfo
```

## Usage

### Loading ComicInfo Files

```ruby
require 'comicinfo'

# Load from file path
comic = ComicInfo.load 'path/to/ComicInfo.xml'

# Load from XML string
xml_content = File.read 'ComicInfo.xml'
comic       = ComicInfo.load xml_content
```

### Accessing Comic Information

```ruby
# Basic information
puts comic.title  #=> "The Amazing Spider-Man"
puts comic.series #=> "The Amazing Spider-Man"
puts comic.number #=> "1"
puts comic.count  #=> 600
puts comic.volume #=> 3

# Publication details
puts comic.publisher #=> "Marvel Comics"
puts comic.year      #=> 2018
puts comic.month     #=> 3
puts comic.day       #=> 15

# Creator information
puts comic.writer       #=> "Dan Slott, Christos Gage"
puts comic.penciller    #=> "Ryan Ottley"
puts comic.cover_artist #=> "Ryan Ottley"

# Content details
puts comic.page_count   #=> 20
puts comic.genres       #=> ["Superhero", "Action", "Adventure"]
puts comic.language_iso #=> "en-US"
puts comic.format       #=> "Digital"

# Ratings and reviews
puts comic.age_rating       #=> "Teen"
puts comic.community_rating #=> 4.25
```

### Convenience Methods

```ruby
# Boolean helpers
puts comic.manga?           #=> false
puts comic.right_to_left?   #=> false
puts comic.black_and_white? #=> false

# Page information
puts comic.pages?       #=> true
puts comic.pages.length #=> 12

# Get specific page types
covers  = comic.cover_pages
stories = comic.story_pages

# Multi-value fields as arrays
characters = comic.characters #=> ["Spider-Man", "Peter Parker", ...]
teams      = comic.teams      #=> ["Avengers"]
locations  = comic.locations  #=> ["New York City", "Manhattan", ...]
genres     = comic.genres     #=> ["Superhero", "Action", "Adventure"]
web_urls   = comic.web_urls   #=> ["https://marvel.com/...", "https://comicvine.com/..."]

# Raw data methods for original comma-separated strings
genres_raw     = comic.genres_raw_data     #=> "Superhero, Action, Adventure"
characters_raw = comic.characters_raw_data #=> "Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May"
story_arcs_raw = comic.story_arcs_raw_data #=> "Brand New Day, Spider-Island"

# Singular schema elements alias to plural arrays
genre          = comic.genre          #=> ["Superhero", "Action", "Adventure"] (same as genres)
story_arc      = comic.story_arc      #=> ["Brand New Day", "Spider-Island"] (same as story_arcs)
story_arc_num  = comic.story_arc_number #=> ["1", "5"] (same as story_arc_numbers)

# Change a list: a copy of the issue (an empty list removes the field)
updated = comic.setting_genres ['Action', ' Adventure', 'Action']
updated.genres_raw_data #=> "Action, Adventure"
# Also setting_characters, setting_locations, setting_teams, setting_web_links
web_links = comic.web_links #=> ["https://marvel.com/...", "https://comicvine.com/..."]
```

### File Names from Templates

Name a comic's file, or its page image files, from its details. The result has no extension.

```ruby
comic.filename template: '{series} #{number} ({year})' #=> "Saga #1 (2012)"
comic.filename template: '{series} #{number:3}'        #=> "Saga #001"

comic.page_filename template: 'page_{page:3}', page: 1, of: 22                 #=> "page_001"
comic.page_filename template: '{series}_{number:3}_{page:4}', page: 12, of: 22 #=> "Saga_001_0012"
```

Write templates in single quotes: in double quotes Ruby reads `#{number}` as interpolation.

- **Tokens**: `{number}` `{publisher}` `{series}` `{title}` `{volume}` `{year}`, and `{page}` in a page template. They are listed in `ComicInfo::FilenameTemplate::TOKENS` and `PAGE_TOKENS`.
- **Padding**: `{number:3}` and `{page:3}` pad with zeros to that many digits. Only the whole number a value starts with is padded: `1.5` becomes `001.5` and `12AU` becomes `012AU`.
- **Missing values** are left out along with the decoration around them: `Saga # ()` becomes `Saga`.
- **`/` and `:`** in a value become `-`, since they cannot be part of a file name.
- **Page names always sort in page order**: the page number is at least as wide as the page count (page 2 of 10 is `02`), and a template without `{page}` gets the number appended.

### Working with Pages

```ruby
comic.pages.each do |page|
  puts "Page #{page.image}: #{page.type}"
  puts "  Double page: #{page.double_page?}"                    if page.double_page?
  puts "  Bookmark: #{page.bookmark}"                           if page.bookmarked?
  puts "  Dimensions: #{page.image_width}x#{page.image_height}" if page.dimensions_available?
end

# Page type checks
page = comic.pages.first
puts page.cover?   #=> true for FrontCover, BackCover, InnerCover
puts page.story?   #=> true for Story pages
puts page.deleted? #=> true for Deleted pages

# A page can carry more than one type (space-separated in the XML)
puts page.type                  #=> "FrontCover"
puts page.types                 #=> ["FrontCover"]
puts page.include_type? 'Story' #=> false
```

### Changing Pages

An issue is not changed in place. These return a changed copy, which you can `save` or turn `to_xml`.

```ruby
# A page's type, by its image index. A page with no <Page> entry is a Story page.
comic.page_type at: 0 #=> "FrontCover"

# Give a page a type. Its entry keeps everything else; a page with no entry gets one.
updated = comic.setting_page_type 'Advertisement', at: 4

# Bring the <Page> entries and PageCount up to date after the page images were reordered,
# deleted, or added to. Each item is the index that image had before, or nil for a new image.
# Here the third page moves to the front, the second is deleted, and a new page is added.
updated = comic.rearranging_pages [2, 0, nil]
updated.save 'ComicInfo.xml'
```

### Manga Support

```ruby
# Load a manga ComicInfo file
manga = ComicInfo.load 'path/to/manga/ComicInfo.xml'

puts manga.title            #=> "進撃の巨人"
puts manga.series           #=> "Attack on Titan"
puts manga.manga            #=> "YesAndRightToLeft"
puts manga.right_to_left?   #=> true
puts manga.language_iso     #=> "ja-JP"
puts manga.black_and_white? #=> true
puts manga.black_and_white  #=> "Yes"
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
rescue ComicInfo::Errors::TypeCoercionError => e
  puts "Type coercion error: #{e.message}"
end
```

## Schema Support

This gem fully supports the ComicInfo v2.0 XSD schema with all field types:

### String Fields
- Title, Series, Number, Summary, Notes
- Creator fields (Writer, Penciller, Inker, Colorist, Letterer, CoverArtist, Editor, Translator)
- Publication fields (Publisher, Imprint, Web, LanguageISO, Format)
- Character/Location fields (MainCharacterOrTeam)
- Story fields (SeriesGroup, ScanInformation, Review)

### Multi-value Fields (String + Array Access)
- Genre/Genres: Raw comma-separated string + parsed array
- Characters: Raw comma-separated string + parsed array
- Teams: Raw comma-separated string + parsed array
- Locations: Raw comma-separated string + parsed array
- StoryArc/StoryArcs: Raw comma-separated string + parsed array
- StoryArcNumber/StoryArcNumbers: Raw comma-separated string + parsed array

### Integer Fields
- Count, Volume, AlternateCount, PageCount
- Date fields (Year, Month, Day)

### Enum Fields
- BlackAndWhite: "Unknown", "No", "Yes"
- Manga: "Unknown", "No", "Yes", "YesAndRightToLeft"
- AgeRating: Various ESRB and international ratings

### Decimal Fields
- CommunityRating: 0.0 to 5.0 range with validation (a `Float`, `nil` when absent)

### Default Values
- Missing string fields are `""`, missing integer fields are `-1`, missing enum fields are `"Unknown"`

### Complex Fields
- Pages: Array of ComicPageInfo objects with full attribute support
- Page types: FrontCover, BackCover, InnerCover, Roundup, Story, Advertisement, Editorial, Letters, Preview, Other, Deleted

### Export Formats
- **JSON**: Complete serialization with all fields
- **YAML**: Human-readable format with array structures
- **XML**: Valid ComicInfo v2.0 compliant XML generation
- **Hash**: Ruby hash representation with symbol keys

### Data Export & XML Generation

```ruby
comic = ComicInfo.load 'path/to/ComicInfo.xml'

# Export as JSON
json_string = comic.to_json
puts JSON.pretty_generate(JSON.parse(json_string))

# Export as YAML
yaml_string = comic.to_yaml
puts yaml_string

# Generate XML
xml_string = comic.to_xml
puts xml_string

# Save to file
comic.save 'path/to/new/ComicInfo.xml'

# Save to IO object
File.open('path/to/new/ComicInfo.xml', 'w') do |file|
  comic.save file
end

# Export as Hash
hash = comic.to_h
puts hash[:title]                   #=> "The Amazing Spider-Man"
puts hash[:genre]                   #=> "Superhero, Action, Adventure" (raw data)
puts hash[:genres]                  #=> ["Superhero", "Action", "Adventure"] (parsed array)
puts hash[:genres_raw_data]         #=> "Superhero, Action, Adventure" (same as :genre)
puts hash[:characters]              #=> ["Spider-Man", "Peter Parker", ...]
puts hash[:characters_raw_data]     #=> "Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May"
puts hash[:pages].length            #=> 12
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`,
which will create a git tag for the version,
push git commits and the created tag,
and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running Tests

```sh
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/comic_info_spec.rb
```

### Code Quality

```sh
# Run RuboCop linter
bundle exec rubocop

# Auto-fix correctable issues
bundle exec rubocop --autocorrect
```

## Implementation Status

### Current Features ✅
- **Core Reading**: Complete ComicInfo.xml parsing
- **XML Writing**: Full ComicInfo.xml generation with round-trip consistency
- **Schema Compliance**: Full ComicInfo v2.0 support
- **Field Types**: String, Integer, Decimal, Enum, Boolean, Arrays
- **Multi-value Fields**: Both string and array access methods
- **Issue & Page Support**: Complete Issue and nested Page objects
- **Error Handling**: Custom exceptions with detailed messages
- **Data Export**: JSON, YAML, and XML serialization
- **Validation**: Enum values, ranges, type coercion
- **Unicode Support**: International characters and special symbols
- **File Names**: Comic and page file names from templates
- **Page Changes**: Set a page's type, and keep page entries in step with reordered, deleted, and added pages

### Planned Features 🚧
- **CLI Tool**: Command-line interface for file manipulation
- **Schema Migration**: Support for multiple ComicInfo versions

### Schema Versions
- ✅ **ComicInfo v2.0**: Full support (current)
- 🚧 **ComicInfo v2.1**: Planned
- 🚧 **ComicInfo v1.0**: Planned

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/veganstraightedge/comicinfo.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the
[code of conduct](https://github.com/veganstraightedge/comicinfo/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ComicInfo project's codebases,
issue trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/veganstraightedge/comicinfo/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgments

- [Anansi Project](https://github.com/anansi-project/comicinfo) for the ComicInfo schema specification
- [Nokogiri](https://nokogiri.org/) for XML parsing capabilities
