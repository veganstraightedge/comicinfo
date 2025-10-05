# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [0.1.0] - 2025-01-XX

### Added
- Initial project structure
- Basic gem skeleton
- Development dependencies setup
