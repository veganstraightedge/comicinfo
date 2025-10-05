# TODO.md - ComicInfo Ruby Gem Roadmap

## Phase 1: Foundation & Setup ✅
- [x] Create TODO.md with roadmap
- [x] Create AGENT.md with development guidelines
- [x] Install and configure dependencies
  - [x] Update Gemfile with required gems
  - [x] Update gemspec with proper metadata
  - [x] Bundle install
- [x] Initial commit of setup files

## Phase 2: Core Reading Functionality ✅
- [x] Implement basic ComicInfo class structure
  - [x] ComicInfo.new constructor
  - [x] ComicInfo.load class method
  - [x] Basic XML parsing with Nokogiri
- [x] Create fixture files for testing
  - [x] Minimal valid ComicInfo.xml
  - [x] Complete ComicInfo.xml with all fields
  - [x] Invalid/malformed XML samples
  - [x] Edge cases (empty fields, special characters)
- [x] Write failing tests for reading functionality
  - [x] Test ComicInfo.load with file path
  - [x] Test ComicInfo.load with string content
  - [x] Test all schema fields are accessible
  - [x] Test error handling for invalid files
- [x] Implement reading functionality to make tests pass

## Phase 3: Schema Field Implementation ✅
- [x] Implement all basic string fields
  - [x] Title, Series, Number, Summary, Notes
  - [x] Creator fields (Writer, Penciller, Inker, etc.)
  - [x] Publisher, Imprint, Genre, Web
  - [x] Characters, Teams, Locations
  - [x] StoryArc, SeriesGroup, MainCharacterOrTeam
  - [x] LanguageISO, Format, ScanInformation, Review
- [x] Implement integer fields with validation
  - [x] Count, Volume, AlternateCount
  - [x] Year, Month, Day
  - [x] PageCount
- [x] Implement enum fields
  - [x] BlackAndWhite (YesNo enum)
  - [x] Manga (Manga enum with YesAndRightToLeft)
  - [x] AgeRating (AgeRating enum)
- [x] Implement decimal fields
  - [x] CommunityRating (0.0-5.0 range)
- [x] Implement Pages array (ComicPageInfo objects)
  - [x] Page attributes (Image, Type, DoublePage, etc.)
  - [x] ComicPageType enum validation

## Phase 4: Advanced Features ✅
- [x] Implement data validation
  - [x] Enum value validation
  - [x] Range validation (CommunityRating)
  - [x] Format validation (dates, ISOs)
- [x] Implement comma-separated field handling
  - [x] Genre, Tags, Characters, Teams, Locations
  - [x] StoryArc with StoryArcNumber correlation
- [x] Add convenience methods
  - [x] Date handling methods
  - [x] Boolean helpers for enums
  - [x] Array methods for multi-value fields

## Phase 5: Writing Functionality (Future)
- [ ] Implement XML generation
- [ ] ComicInfo#save method
- [ ] ComicInfo#to_xml method
- [ ] Preserve original formatting when possible

## Phase 6: Testing & Quality (Partial) ✅
- [x] Comprehensive test coverage (139 tests covering all functionality)
- [ ] Performance testing with large files
- [ ] Memory usage optimization
- [ ] Documentation generation
- [ ] Example usage in README

## Phase 7: Schema Version Support
- [ ] Support ComicInfo v1.0 schema
- [ ] Support ComicInfo v2.1 draft schema
- [ ] Version detection and migration

## Development Standards ✅
- [x] All code must pass RuboCop linting
- [x] All tests must pass before commits
- [x] Test-driven development (failing tests first)
- [x] Comprehensive fixture files (no inline XML)
- [x] Idiomatic Ruby patterns throughout
- [x] Ruby 3.4.6+ compatibility maintained

## Notes
- Focus on reading functionality first
- Use Nokogiri for all XML operations
- RSpec for comprehensive test suite
- All enum values should be validated against schema
- Handle malformed XML gracefully
- Support both file paths and XML strings in .load method