# frozen_string_literal: true

require 'nokogiri'
require 'date'
require_relative 'enums'
require_relative 'errors'
require_relative 'page'

module ComicInfo
  # Main class for parsing and accessing ComicInfo.xml data
  # Follows the ComicInfo XSD schema v2.0 specification
  class Issue
    # String fields from ComicInfo schema
    attr_reader :title, :series, :number, :alternate_series, :alternate_number,
                :summary, :notes, :writer, :penciller, :inker, :colorist,
                :letterer, :cover_artist, :editor, :translator, :publisher,
                :imprint, :genre, :web, :language_iso, :format, :character,
                :team, :location, :scan_information, :story_arc, :story_arc_number,
                :series_group, :main_character_or_team, :review

    # Integer fields from ComicInfo schema
    attr_reader :count, :volume, :alternate_count, :year, :month, :day, :page_count

    # Enum fields from ComicInfo schema
    attr_reader :black_and_white, :manga, :age_rating

    # Decimal fields from ComicInfo schema
    attr_reader :community_rating

    # Array fields from ComicInfo schema
    attr_reader :pages

    # Class method to load ComicInfo from file path or XML string
    def self.load file_path_or_xml_string
      raise Errors::ParseError, 'Input cannot be nil' if file_path_or_xml_string.nil?

      input = file_path_or_xml_string.to_s
      return new(input) if input.empty?

      if looks_like_xml?(input)
        new(input)
      else
        load_from_file(input)
      end
    end

    private_class_method def self.looks_like_xml? input
      input.strip.start_with?('<')
    end

    private_class_method def self.load_from_file input
      validate_file_path(input)
      raise Errors::FileError, "File does not exist: '#{input}'" unless File.exist?(input)

      begin
        xml_content = File.read(input)
        new(xml_content)
      rescue Errors::ParseError
        # Re-raise parse errors from XML parsing
        raise
      rescue StandardError => e
        raise Errors::FileError, "Failed to read file '#{input}': #{e.message}"
      end
    end

    private_class_method def self.validate_file_path input
      return unless input.match?(/^\d+$/) ||
                    (!input.include?('.') && !input.include?('/') && !input.include?('\\'))

      raise Errors::ParseError, "Input '#{input}' does not appear to be valid XML or a file path"
    end

    # Initialize from XML string
    def initialize xml_string
      raise Errors::ParseError, 'XML string cannot be nil or empty' if xml_string.nil? || xml_string.empty?

      begin
        @doc = Nokogiri::XML(xml_string) do |config|
          config.strict.nonet
        end

        raise Errors::ParseError, "XML parsing failed: #{@doc.errors.first.message}" if @doc.errors.any?

        @root = @doc.at_xpath('//ComicInfo')
        raise Errors::ParseError, 'No ComicInfo root element found' if @root.nil?
      rescue Nokogiri::XML::SyntaxError => e
        raise Errors::ParseError, "Invalid XML syntax: #{e.message}"
      end

      parse_fields
    end

    # Convenience methods for boolean checks
    def manga?
      Enums::Helpers.yes_value?(@manga)
    end

    def right_to_left?
      Enums::Helpers.manga_right_to_left?(@manga)
    end

    def black_and_white?
      Enums::Helpers.yes_value?(@black_and_white)
    end

    def pages?
      @pages && !@pages.empty?
    end

    # Get only cover pages
    def cover_pages
      return [] unless pages?

      @pages.select(&:cover?)
    end

    # Get only story pages
    def story_pages
      return [] unless pages?

      @pages.select(&:story?)
    end

    # Get publication date as Date object if available
    def publication_date
      return nil if @year == Enums::DEFAULT_INTEGER

      year = @year
      month = @month == Enums::DEFAULT_INTEGER ? 1 : @month
      day = @day == Enums::DEFAULT_INTEGER ? 1 : @day

      begin
        Date.new(year, month, day)
      rescue ArgumentError
        nil
      end
    end

    # Plural methods that return arrays
    def genres
      split_comma_separated(@genre)
    end

    def characters
      split_comma_separated(@character)
    end

    def teams
      split_comma_separated(@team)
    end

    def locations
      split_comma_separated(@location)
    end

    def story_arcs
      split_comma_separated(@story_arc)
    end

    def story_arc_numbers
      split_comma_separated(@story_arc_number)
    end

    def web_urls
      return [] if @web.empty?

      @web.split(/\s+/)
    end

    private

    def parse_fields
      # String fields
      @title = get_string_field('Title')
      @series = get_string_field('Series')
      @number = get_string_field('Number')
      @alternate_series = get_string_field('AlternateSeries')
      @alternate_number = get_string_field('AlternateNumber')
      @summary = get_string_field('Summary')
      @notes = get_string_field('Notes')

      # Creator fields
      @writer = get_string_field('Writer')
      @penciller = get_string_field('Penciller')
      @inker = get_string_field('Inker')
      @colorist = get_string_field('Colorist')
      @letterer = get_string_field('Letterer')
      @cover_artist = get_string_field('CoverArtist')
      @editor = get_string_field('Editor')
      @translator = get_string_field('Translator')

      # Publication fields
      @publisher = get_string_field('Publisher')
      @imprint = get_string_field('Imprint')
      @genre = get_string_field('Genre')
      @web = get_string_field('Web')
      @language_iso = get_string_field('LanguageISO')
      @format = get_string_field('Format')

      # Multi-value string fields (singular names for string values)
      @character = get_string_field('Characters')
      @team = get_string_field('Teams')
      @location = get_string_field('Locations')
      @scan_information = get_string_field('ScanInformation')
      @story_arc = get_string_field('StoryArc')
      @story_arc_number = get_string_field('StoryArcNumber')
      @series_group = get_string_field('SeriesGroup')
      @main_character_or_team = get_string_field('MainCharacterOrTeam')
      @review = get_string_field('Review')

      # Integer fields
      @count = get_integer_field('Count')
      @volume = get_integer_field('Volume')
      @alternate_count = get_integer_field('AlternateCount')
      @year = Enums::Validators.validate_year(get_field_text('Year'))
      @month = Enums::Validators.validate_month(get_field_text('Month'))
      @day = Enums::Validators.validate_day(get_field_text('Day'))
      @page_count = get_integer_field('PageCount', Enums::DEFAULT_PAGE_COUNT)

      # Enum fields
      @black_and_white = Enums::Validators.validate_yes_no(get_field_text('BlackAndWhite'))
      @manga = Enums::Validators.validate_manga(get_field_text('Manga'))
      @age_rating = Enums::Validators.validate_age_rating(get_field_text('AgeRating'))

      # Decimal fields
      @community_rating = Enums::Validators.validate_community_rating(get_field_text('CommunityRating'))

      # Array fields
      @pages = parse_pages
    end

    def get_string_field field_name
      text = get_field_text(field_name)
      text.nil? || text.empty? ? Enums::DEFAULT_STRING : text
    end

    def get_integer_field field_name, default = Enums::DEFAULT_INTEGER
      text = get_field_text(field_name)
      Enums::Validators.validate_integer(text, field_name, default)
    end

    def get_field_text field_name
      element = @root.at_xpath(field_name)
      element&.text
    end

    def parse_pages
      pages_element = @root.at_xpath('Pages')
      return [] unless pages_element

      page_elements = pages_element.xpath('Page')
      page_elements.map do |page_element|
        attributes = {}
        page_element.attributes.each do |name, attr|
          attributes[name] = attr.value
        end
        Page.new(attributes)
      end
    end

    def split_comma_separated text
      return [] if text.nil? || text.empty?

      text.split(/,\s*/).map(&:strip).reject(&:empty?)
    end
  end
end
