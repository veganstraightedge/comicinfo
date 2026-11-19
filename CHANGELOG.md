# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2026-11-19

### Added
- `ComicInfo::Issue#rearranging_pages(order)`: a copy of the issue with its `<Page>` entries and `PageCount` brought up to date after page images were reordered, deleted, or added. Entries follow their image to its new index, deleted pages lose theirs, and new pages get a default entry when the issue has page entries at all
- `ComicInfo::Issue#page_type(at:)` and `ComicInfo::Issue#setting_page_type(type, at:)`: read and set the type of a page image by its index. A page with no `<Page>` entry is a Story page; setting another type on it adds an entry, and an existing entry keeps its other details
- `ComicInfo::Page#with_image(image)` and `ComicInfo::Page#with_type(type)`: a copy of a page entry pointing at another image, or with another type
- `ComicInfo::Issue#filename(template:)`: a file name for the issue from a template such as `{series} #{number} ({year})` ("Saga #1 (2012)"). Missing values are left out along with the decoration around them, `/` and `:` in values become `-`, and `{number:3}` pads the issue number with zeros ("Saga #001")
- `ComicInfo::Issue#page_filename(template:, page:, of:)`: a file name for one page image, from a template such as `page_{page:3}` or `{series}_{number:3}_{page:4}`. The page number is always at least as wide as the page count, and a template without one gets it appended, so the names keep pages apart and in order
- `ComicInfo::FilenameTemplate`, which does the filling in, with the tokens it knows in `TOKENS` and `PAGE_TOKENS`

### Changed
- Bump Ruby version from 3.4.6 to 4.0.9 (`.ruby-version`, `required_ruby_version`, rubocop `TargetRubyVersion`, CI matrix)
- Update RuboCop to 1.87.0 (supports Ruby 4.0 `TargetRubyVersion`)
- Corrected the README and `doc/development.md` where they described methods that do not exist (`#character`, `#team`) or the wrong return types (`#genre` returns an array, `CommunityRating` is a `Float`), and dropped already-shipped features from the future list

## [2.0.0] - 2025-11-10

### Added
- **XML Generation**: Complete ComicInfo XML writing functionality
  - `ComicInfo::Issue#to_xml` method for generating XML strings
  - `ComicInfo::Issue#save(file_path_or_io)` method for writing to files or IO objects
  - Valid ComicInfo v2.0 compliant XML output with UTF-8 encoding and schema namespaces
  - Only includes non-default/non-empty values for clean XML output
  - Proper XML entity escaping for special characters
  - Full Pages section generation with all page attributes
  - Round-trip consistency (load -> save -> load maintains data integrity)

### Changed - BREAKING
- **Multi-value field method naming**: Changed from singular/plural pattern to plural/raw_data pattern
  - Plural methods (e.g., `genres`, `characters`) now return arrays
  - Raw data methods (e.g., `genres_raw_data`, `characters_raw_data`) return original comma-separated strings
  - Singular schema elements now alias to plural methods (e.g., `genre` aliases to `genres`)
  - Export hashes include both raw data keys and _raw_data keys with duplicate values for backward compatibility
  - This affects: `genre`/`genres`, `character`/`characters`, `team`/`teams`, `location`/`locations`, `story_arc`/`story_arcs`, `story_arc_number`/`story_arc_numbers`

### Migration Guide
- Replace `.genre` calls with `.genres` (now returns array) or `.genres_raw_data` (for string)
- Replace `.character` calls with `.characters_raw_data` (for string) - `.characters` was already array
- Replace `.team` calls with `.teams_raw_data` (for string) - `.teams` was already array
- Replace `.location` calls with `.locations_raw_data` (for string) - `.locations` was already array
- Replace `.story_arc` calls with `.story_arcs` (now returns array) or `.story_arcs_raw_data` (for string)
- Replace `.story_arc_number` calls with `.story_arc_numbers` (now returns array) or `.story_arc_numbers_raw_data` (for string)

### Export Hash Changes
- Hash exports now include both `:genre` and `:genres_raw_data` keys with identical raw string values
- Hash exports now include both `:story_arc` and `:story_arcs_raw_data` keys with identical raw string values
- Hash exports now include both `:story_arc_number` and `:story_arc_numbers_raw_data` keys with identical raw string values
- This maintains backward compatibility while supporting the new API design

## [1.0.0] - 2025-10-05

### Added
- Complete ComicInfo v2.0 XML schema support
- `ComicInfo.load()` method for loading from file paths or XML strings
- `ComicInfo::Issue` class with full field access via Ruby method names
- `ComicInfo::Page` objects with complete ComicPageInfo attribute support
- Multi-value field support with both string and array access methods
- Comprehensive enum validation for BlackAndWhite, Manga, AgeRating fields
- Range validation for CommunityRating (0.0-5.0)
- Unicode and international character support
- Manga-specific features (right-to-left detection, language handling)
- JSON export via `#to_json` method
- YAML export via `#to_yaml` method
- Hash export via `#to_h` method with symbol keys
- Convenience predicate methods (`#manga?`, `#right_to_left?`, `#black_and_white?`)
- Page filtering methods (`#cover_pages`, `#story_pages`)
- Custom exception classes with detailed error messages
- Comprehensive test suite

### Features
- **Reading**: Load and parse ComicInfo.xml files with full schema compliance
- **Validation**: Strict enum and range validation with helpful error messages
- **Export**: Multiple export formats (JSON, YAML, Hash) for data interchange
- **Unicode**: Full support for international characters and XML entities
- **Pages**: Complete page object model with type predicates and attributes
- **Multi-value**: Smart handling of comma/space-separated field values

## [0.1.0] - 2025-10-05

### Added
- Initial project structure
- Basic gem skeleton
- Development dependencies setup
