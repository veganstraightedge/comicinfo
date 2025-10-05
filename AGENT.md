# AGENT.md - Development Guidelines for ComicInfo Ruby Gem

## Project Overview
This Ruby gem provides an idiomatic interface for working with ComicInfo.xml files, following the official ComicInfo schema specifications from the Anansi Project.

## Development Philosophy
- **Test-Driven Development**: Write failing tests first, then implement functionality
- **Idiomatic Ruby**: Follow Ruby conventions and best practices
- **Schema Compliance**: Strict adherence to ComicInfo XSD schema definitions
- **Error Handling**: Graceful handling of malformed XML and invalid data
- **Performance**: Efficient XML parsing and memory usage

## Code Standards

### Ruby Version
- Minimum required: Ruby 3.4.6+
- Use modern Ruby features and syntax patterns

### Dependencies
- **nokogiri** (>= 1.18.10): XML parsing and generation
- **rspec** (>= 3.13.1): Testing framework
- **rubocop** (>= 1.81.1): Code linting and formatting

### Code Style
- Follow RuboCop rules (configured in `.rubocop.yml`)
- Use 2-space indentation
- Maximum line length: 120 characters
- Prefer explicit returns in public methods
- Use descriptive variable and method names

### Testing Guidelines
- Use RSpec for all tests
- Create fixture files for test data (no inline XML strings)
- Test both happy path and error conditions
- Aim for >95% test coverage
- Group related tests in describe/context blocks
- Use descriptive test descriptions

### File Organization
```
lib/
├── comicinfo.rb              # Main module and autoloads
├── comicinfo/
│   ├── version.rb            # Gem version constant
│   ├── issue.rb              # Main ComicInfo::Issue class
│   ├── page.rb               # ComicInfo::Page class
│   ├── enums.rb              # Schema enum definitions
│   └── errors.rb             # Custom exception classes
spec/
├── spec_helper.rb            # RSpec configuration with FixtureHelpers
├── comic_info_spec.rb        # Main module specs
├── comic_info/
│   ├── issue_spec.rb         # ComicInfo::Issue class specs
│   ├── page_spec.rb          # ComicInfo::Page class specs
│   └── fixtures/             # XML test fixtures
│       ├── valid_minimal.xml
│       ├── valid_complete.xml
│       ├── invalid_xml.xml
│       └── edge_cases/
└── fixtures/                 # Additional fixtures for top-level specs
```

## API Design Principles

### Class Interface
```ruby
# Primary interface
ComicInfo.load(file_path_or_xml_string) #=> ComicInfo::Issue instance
ComicInfo::Issue.new(xml_string) #=> ComicInfo::Issue instance

# Instance methods match schema fields
comic.title #=> String
comic.series #=> String
comic.count #=> Integer
comic.black_and_white #=> String (enum value)
comic.pages #=> Array<ComicInfo::Page>

# Multi-value fields have both singular and plural methods
comic.character #=> String (comma-separated)
comic.characters #=> Array<String>
comic.genre #=> String (comma-separated)
comic.genres #=> Array<String>
comic.web #=> String (space-separated URLs)
comic.web_urls #=> Array<String>
```

### Naming Conventions
- Class names: `ComicInfo::Issue`, `ComicInfo::Page`
- Method names: snake_case following Ruby conventions
- Schema field mapping:
  - XML `<Title>` → Ruby `#title`
  - XML `<BlackAndWhite>` → Ruby `#black_and_white`
  - XML `<CommunityRating>` → Ruby `#community_rating`
- Multi-value fields:
  - Singular method returns original string from XML
  - Plural method returns array of split values
  - XML `<Characters>` → Ruby `#character` (string) & `#characters` (array)
  - XML `<Teams>` → Ruby `#team` (string) & `#teams` (array)

### Error Handling
- Define custom exception classes in `ComicInfo::Errors`
- Validate enum values against schema definitions
- Provide meaningful error messages for invalid data
- Handle XML parsing errors gracefully

## Development Workflow

### Before Starting Work
1. Read the relevant ComicInfo schema documentation
2. Understand the XML structure and constraints
3. Plan the Ruby interface design

### Development Process
1. Write failing tests with fixture files
2. Implement minimal code to make tests pass
3. Refactor for clarity and performance
4. Run RuboCop to ensure code style compliance
5. Verify all tests pass
6. Update documentation if needed

### Before Committing
```bash
# Run linter (must pass)
bundle exec rubocop

# Run tests (must all pass)
bundle exec rspec

# Check test coverage
bundle exec rspec --format documentation
```

### Commit Standards
- Never commit failing tests
- Mark unimplemented tests as `skip` or `pending`
- Use descriptive commit messages
- Keep commits focused and atomic

## Schema Implementation Notes

### Enum Handling
- Validate all enum values against XSD schema
- Provide constants for valid enum values
- Return original string values, not symbols

### Multi-value Fields
- Handle comma-separated values in fields like Genre, Characters
- Provide both string and array access methods
- Preserve original formatting when possible

### Type Coercion
- String fields: preserve as-is from XML
- Integer fields: convert with proper error handling
- Decimal fields: use BigDecimal for precision
- Boolean attributes: handle "true"/"false" strings

### Default Values
- Follow XSD schema default values
- Empty strings for string fields
- -1 for unset integer fields
- "Unknown" for enum fields where applicable

## Testing Strategy

### Fixture Files
Create comprehensive XML fixtures covering:
- Minimal valid ComicInfo.xml (required fields only)
- Complete ComicInfo.xml (all fields populated)
- Invalid XML (malformed syntax)
- Invalid data (enum violations, out-of-range values)
- Edge cases (special characters, Unicode, empty elements)

### Test Categories
1. **Unit tests**: Individual method behavior
2. **Integration tests**: Full XML parsing workflows
3. **Error handling tests**: Invalid inputs and edge cases
4. **Fixture helpers**: Centralized test data management

### Test Organization
```ruby
RSpec.describe ComicInfo::Issue do
  describe '.load' do
    context 'with valid file path' do
      it 'loads from fixture' do
        comic = load_fixture('valid_minimal.xml')
        expect(comic.title).to eq('Expected Title')
      end
    end
    
    context 'with XML string' do
      it 'parses XML content' do
        xml_content = fixture_file('valid_complete.xml')
        comic = described_class.new(xml_content)
        expect(comic.series).to eq('Expected Series')
      end
    end
  end
  
  describe 'multi-value fields' do
    describe 'singular methods (return strings)' do
      # Test comma-separated string values
    end
    
    describe 'plural methods (return arrays)' do
      # Test array conversion
    end
  end
end
```

## Performance Considerations
- Use Nokogiri's efficient XML parsing with CSS selectors
- ComicInfo.xml files are typically small (<100KB)
- Focus on code clarity over micro-optimizations
- Cache parsed values to avoid re-parsing

## Documentation
- Maintain comprehensive README with examples
- Document all public methods with YARD comments
- Include schema field descriptions in code comments
- Support multiple schema versions (1.0, 2.0, 2.1-draft)

## Future Considerations
- XML writing/generation capabilities (.to_xml method)
- JSON export (.to_json method)
- YAML export (.to_yaml method)
- Schema version detection and migration
- CLI tool for ComicInfo manipulation
