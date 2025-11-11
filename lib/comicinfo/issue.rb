require 'nokogiri'
require 'date'
require 'json'
require 'yaml'
require 'fileutils'
require_relative 'enums'
require_relative 'errors'
require_relative 'page'

module ComicInfo
  # Main class for parsing and accessing ComicInfo.xml data
  # Follows the ComicInfo XSD schema v2.0 specification
  class Issue
    # String fields from ComicInfo schema
    attr_reader :alternate_number, :alternate_series, :colorist, :cover_artist, :editor,
                :format, :imprint, :inker, :language_iso, :letterer, :main_character_or_team,
                :notes, :number, :penciller, :publisher, :review, :scan_information, :series,
                :series_group, :summary, :title, :translator, :web, :writer

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

        @root = @doc.at_css('ComicInfo')
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
    def genres            = split_comma_separated @genre
    def characters        = split_comma_separated @character
    def teams             = split_comma_separated @team
    def locations         = split_comma_separated @location
    def story_arcs        = split_comma_separated @story_arc
    def story_arc_numbers = split_comma_separated @story_arc_number

    def web_urls
      return [] if @web.empty?

      @web.split(/\s+/)
    end

    # Raw data methods that return the original string values
    def genres_raw_data            = @genre
    def characters_raw_data        = @character
    def teams_raw_data             = @team
    def locations_raw_data         = @location
    def story_arcs_raw_data        = @story_arc
    def story_arc_numbers_raw_data = @story_arc_number

    # Singular aliases for schema elements that are singular
    alias genre genres
    alias story_arc story_arcs
    alias story_arc_number story_arc_numbers

    # Convert to XML representation
    def to_xml
      doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.ComicInfo('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                      'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') do
          # String fields in schema order
          xml.Title(@title) unless @title == Enums::DEFAULT_STRING
          xml.Series(@series) unless @series == Enums::DEFAULT_STRING
          xml.Number(@number) unless @number == Enums::DEFAULT_STRING
          xml.Count(@count) unless @count == Enums::DEFAULT_INTEGER
          xml.Volume(@volume) unless @volume == Enums::DEFAULT_INTEGER
          xml.AlternateSeries(@alternate_series) unless @alternate_series == Enums::DEFAULT_STRING
          xml.AlternateNumber(@alternate_number) unless @alternate_number == Enums::DEFAULT_STRING
          xml.AlternateCount(@alternate_count) unless @alternate_count == Enums::DEFAULT_INTEGER
          xml.Summary(@summary) unless @summary == Enums::DEFAULT_STRING
          xml.Notes(@notes) unless @notes == Enums::DEFAULT_STRING
          xml.Year(@year) unless @year == Enums::DEFAULT_INTEGER
          xml.Month(@month) unless @month == Enums::DEFAULT_INTEGER
          xml.Day(@day) unless @day == Enums::DEFAULT_INTEGER
          xml.Writer(@writer) unless @writer == Enums::DEFAULT_STRING
          xml.Penciller(@penciller) unless @penciller == Enums::DEFAULT_STRING
          xml.Inker(@inker) unless @inker == Enums::DEFAULT_STRING
          xml.Colorist(@colorist) unless @colorist == Enums::DEFAULT_STRING
          xml.Letterer(@letterer) unless @letterer == Enums::DEFAULT_STRING
          xml.CoverArtist(@cover_artist) unless @cover_artist == Enums::DEFAULT_STRING
          xml.Editor(@editor) unless @editor == Enums::DEFAULT_STRING
          xml.Translator(@translator) unless @translator == Enums::DEFAULT_STRING
          xml.Publisher(@publisher) unless @publisher == Enums::DEFAULT_STRING
          xml.Imprint(@imprint) unless @imprint == Enums::DEFAULT_STRING
          xml.Genre(@genre) unless @genre == Enums::DEFAULT_STRING
          xml.Web(@web) unless @web == Enums::DEFAULT_STRING
          xml.PageCount(@page_count) unless @page_count == Enums::DEFAULT_PAGE_COUNT
          xml.LanguageISO(@language_iso) unless @language_iso == Enums::DEFAULT_STRING
          xml.Format(@format) unless @format == Enums::DEFAULT_STRING
          xml.BlackAndWhite(@black_and_white) unless @black_and_white == Enums::DEFAULT_ENUM_UNKNOWN
          xml.Manga(@manga) unless @manga == Enums::DEFAULT_ENUM_UNKNOWN
          xml.Characters(@character) unless @character == Enums::DEFAULT_STRING
          xml.Teams(@team) unless @team == Enums::DEFAULT_STRING
          xml.Locations(@location) unless @location == Enums::DEFAULT_STRING
          xml.ScanInformation(@scan_information) unless @scan_information == Enums::DEFAULT_STRING
          xml.StoryArc(@story_arc) unless @story_arc == Enums::DEFAULT_STRING
          xml.StoryArcNumber(@story_arc_number) unless @story_arc_number == Enums::DEFAULT_STRING
          xml.SeriesGroup(@series_group) unless @series_group == Enums::DEFAULT_STRING
          xml.AgeRating(@age_rating) unless @age_rating == Enums::DEFAULT_ENUM_UNKNOWN
          xml.MainCharacterOrTeam(@main_character_or_team) unless @main_character_or_team == Enums::DEFAULT_STRING
          xml.CommunityRating(@community_rating) unless @community_rating.nil?
          xml.Review(@review) unless @review == Enums::DEFAULT_STRING

          # Pages section
          if @pages && !@pages.empty?
            xml.Pages do
              @pages.each do |page|
                xml.Page(page.to_xml_attributes)
              end
            end
          end
        end
      end

      doc.to_xml
    end

    # Save to file or IO object
    def save file_path_or_io
      xml_content = to_xml

      case file_path_or_io
      when String
        begin
          FileUtils.mkdir_p(File.dirname(file_path_or_io))
          File.write(file_path_or_io, xml_content)
        rescue StandardError => e
          raise Errors::FileError, "Failed to write file '#{file_path_or_io}': #{e.message}"
        end
      when IO
        begin
          file_path_or_io.write(xml_content)
        rescue StandardError => e
          raise Errors::FileError, "Failed to write to IO object: #{e.message}"
        end
      else
        raise Errors::FileError, 'Invalid file path or IO object'
      end
    end

    # Convert to JSON representation
    def to_json(*)
      to_h.to_json(*)
    end

    # Convert to YAML representation
    def to_yaml(*)
      to_h.to_yaml(*)
    end

    # Convert to hash representation for JSON serialization
    def to_h
      {
        title:                      @title,
        series:                     @series,
        number:                     @number,
        count:                      @count,
        volume:                     @volume,
        alternate_series:           @alternate_series,
        alternate_number:           @alternate_number,
        alternate_count:            @alternate_count,
        summary:                    @summary,
        notes:                      @notes,
        year:                       @year,
        month:                      @month,
        day:                        @day,
        writer:                     @writer,
        penciller:                  @penciller,
        inker:                      @inker,
        colorist:                   @colorist,
        letterer:                   @letterer,
        cover_artist:               @cover_artist,
        editor:                     @editor,
        translator:                 @translator,
        publisher:                  @publisher,
        imprint:                    @imprint,
        genre:                      @genre,
        genres_raw_data:            genres_raw_data,
        genres:                     genres,
        web:                        @web,
        web_urls:                   web_urls,
        page_count:                 @page_count,
        language_iso:               @language_iso,
        format:                     @format,
        black_and_white:            @black_and_white,
        manga:                      @manga,
        characters_raw_data:        characters_raw_data,
        characters:                 characters,
        teams_raw_data:             teams_raw_data,
        teams:                      teams,
        locations_raw_data:         locations_raw_data,
        locations:                  locations,
        scan_information:           @scan_information,
        story_arc:                  @story_arc,
        story_arcs_raw_data:        story_arcs_raw_data,
        story_arcs:                 story_arcs,
        story_arc_number:           @story_arc_number,
        story_arc_numbers_raw_data: story_arc_numbers_raw_data,
        story_arc_numbers:          story_arc_numbers,
        series_group:               @series_group,
        age_rating:                 @age_rating,
        main_character_or_team:     @main_character_or_team,
        community_rating:           @community_rating,
        review:                     @review,
        pages:                      @pages.map(&:to_h)
      }.compact
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
      element = @root.at_css(field_name)
      element&.text
    end

    def parse_pages
      pages_element = @root.at_css('Pages')
      return [] unless pages_element

      page_elements = pages_element.css('Page')
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
