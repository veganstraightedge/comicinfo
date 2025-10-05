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

## Phase 5: Export Functionality (Partial) 🚧
- [x] JSON export functionality
  - [x] ComicInfo#to_json method
  - [x] ComicInfo#to_h method for hash representation
  - [x] Include both singular and plural forms
- [x] YAML export functionality (needs Symbol class support fix)
  - [x] ComicInfo#to_yaml method
  - [ ] Fix YAML.safe_load compatibility with symbols
- [ ] XML writing/generation functionality
  - [ ] ComicInfo#to_xml method
  - [ ] ComicInfo#save method
  - [ ] Preserve original formatting when possible

## Phase 6: Testing & Quality ✅
- [x] Comprehensive test coverage (156 tests covering all functionality)
- [x] Code alignment standards implemented
  - [x] Align expect statements within same it blocks
  - [x] Maintain consistent formatting patterns
  - [x] Follow Ruby test formatting best practices
- [x] Error handling validation
  - [x] Custom exception classes with detailed messages
  - [x] Enum validation error messages
  - [x] Range validation error messages
- [ ] Performance testing with large files
- [ ] Memory usage optimization
- [ ] Documentation generation
- [x] Example usage in README

## Phase 7: Schema Version Support (Future)
- [ ] Support ComicInfo v1.0 schema
- [ ] Support ComicInfo v2.1 draft schema
- [ ] Version detection and migration

## Phase 8: Missing Test Fixtures ⚠️
- [ ] Create missing edge case fixtures
  - [ ] edge_cases/empty_fields.xml
  - [ ] edge_cases/unicode_characters.xml
  - [ ] edge_cases/manga_rtl.xml
- [ ] Fix test expectations for error message patterns
- [ ] Implement missing convenience methods referenced in tests

## Development Standards ✅
- [x] All code must pass RuboCop linting
- [x] All tests must pass before commits
- [x] Test-driven development (failing tests first)
- [x] Comprehensive fixture files (no inline XML)
- [x] Idiomatic Ruby patterns throughout
- [x] Ruby 3.4.6+ compatibility maintained
- [x] Code alignment within test blocks for readability

## Current Status
- ✅ **Core Reading**: Fully implemented with comprehensive test coverage
- ✅ **Schema Compliance**: All ComicInfo v2.0 fields supported
- ✅ **Error Handling**: Custom exceptions with detailed error messages  
- ✅ **Multi-value Fields**: Both string and array access methods
- ✅ **Page Support**: Full ComicPageInfo object implementation
- 🚧 **Export Features**: JSON complete, YAML needs symbol support fix
- ⚠️ **Test Fixtures**: Some edge case fixtures missing (7 failing tests)
- 🚧 **XML Generation**: Not yet implemented

## Notes
- Focus on reading functionality first ✅
- Use Nokogiri for all XML operations ✅
- RSpec for comprehensive test suite ✅
- All enum values should be validated against schema ✅
- Handle malformed XML gracefully ✅
- Support both file paths and XML strings in .load method ✅
- Next priority: Fix missing test fixtures and YAML symbol support