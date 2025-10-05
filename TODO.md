# TODO.md - ComicInfo Ruby Gem Roadmap

## Phase 1: Foundation & Setup ✅
- [x] Create TODO.md with roadmap
- [x] Create AGENT.md with development guidelines
- [ ] Install and configure dependencies
  - [ ] Update Gemfile with required gems
  - [ ] Update gemspec with proper metadata
  - [ ] Bundle install
- [ ] Initial commit of setup files

## Phase 2: Core Reading Functionality
- [ ] Implement basic ComicInfo class structure
  - [ ] ComicInfo.new constructor
  - [ ] ComicInfo.load class method
  - [ ] Basic XML parsing with Nokogiri
- [ ] Create fixture files for testing
  - [ ] Minimal valid ComicInfo.xml
  - [ ] Complete ComicInfo.xml with all fields
  - [ ] Invalid/malformed XML samples
  - [ ] Edge cases (empty fields, special characters)
- [ ] Write failing tests for reading functionality
  - [ ] Test ComicInfo.load with file path
  - [ ] Test ComicInfo.load with string content
  - [ ] Test all schema fields are accessible
  - [ ] Test error handling for invalid files
- [ ] Implement reading functionality to make tests pass

## Phase 3: Schema Field Implementation
- [ ] Implement all basic string fields
  - [ ] Title, Series, Number, Summary, Notes
  - [ ] Creator fields (Writer, Penciller, Inker, etc.)
  - [ ] Publisher, Imprint, Genre, Web
  - [ ] Characters, Teams, Locations
  - [ ] StoryArc, SeriesGroup, MainCharacterOrTeam
  - [ ] LanguageISO, Format, ScanInformation, Review
- [ ] Implement integer fields with validation
  - [ ] Count, Volume, AlternateCount
  - [ ] Year, Month, Day
  - [ ] PageCount
- [ ] Implement enum fields
  - [ ] BlackAndWhite (YesNo enum)
  - [ ] Manga (Manga enum with YesAndRightToLeft)
  - [ ] AgeRating (AgeRating enum)
- [ ] Implement decimal fields
  - [ ] CommunityRating (0.0-5.0 range)
- [ ] Implement Pages array (ComicPageInfo objects)
  - [ ] Page attributes (Image, Type, DoublePage, etc.)
  - [ ] ComicPageType enum validation

## Phase 4: Advanced Features
- [ ] Implement data validation
  - [ ] Enum value validation
  - [ ] Range validation (CommunityRating)
  - [ ] Format validation (dates, ISOs)
- [ ] Implement comma-separated field handling
  - [ ] Genre, Tags, Characters, Teams, Locations
  - [ ] StoryArc with StoryArcNumber correlation
- [ ] Add convenience methods
  - [ ] Date handling methods
  - [ ] Boolean helpers for enums
  - [ ] Array methods for multi-value fields

## Phase 5: Writing Functionality (Future)
- [ ] Implement XML generation
- [ ] ComicInfo#save method
- [ ] ComicInfo#to_xml method
- [ ] Preserve original formatting when possible

## Phase 6: Testing & Quality
- [ ] Comprehensive test coverage (>95%)
- [ ] Performance testing with large files
- [ ] Memory usage optimization
- [ ] Documentation generation
- [ ] Example usage in README

## Phase 7: Schema Version Support
- [ ] Support ComicInfo v1.0 schema
- [ ] Support ComicInfo v2.1 draft schema
- [ ] Version detection and migration

## Development Standards
- [ ] All code must pass RuboCop linting
- [ ] All tests must pass before commits
- [ ] Test-driven development (failing tests first)
- [ ] Comprehensive fixture files (no inline XML)
- [ ] Idiomatic Ruby patterns throughout
- [ ] Ruby 3.4.6+ compatibility maintained

## Notes
- Focus on reading functionality first
- Use Nokogiri for all XML operations
- RSpec for comprehensive test suite
- All enum values should be validated against schema
- Handle malformed XML gracefully
- Support both file paths and XML strings in .load method