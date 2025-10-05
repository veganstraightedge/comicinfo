# frozen_string_literal: true

module ComicInfo
  module Enums
    # YesNo enum values for BlackAndWhite field
    YES_NO_VALUES = %w[Unknown No Yes].freeze

    # Manga enum values including right-to-left reading direction
    MANGA_VALUES = %w[Unknown No Yes YesAndRightToLeft].freeze

    # Age rating enum values from ComicInfo schema
    AGE_RATING_VALUES = [
      'Unknown',
      'Adults Only 18+',
      'Early Childhood',
      'Everyone',
      'Everyone 10+',
      'G',
      'Kids to Adults',
      'M',
      'MA15+',
      'Mature 17+',
      'PG',
      'R18+',
      'Rating Pending',
      'Teen',
      'X18+'
    ].freeze

    # Comic page type enum values
    COMIC_PAGE_TYPE_VALUES = %w[
      FrontCover
      InnerCover
      Roundup
      Story
      Advertisement
      Editorial
      Letters
      Preview
      BackCover
      Other
      Deleted
    ].freeze

    # Default values from XSD schema
    DEFAULT_STRING = ''
    DEFAULT_INTEGER = -1
    DEFAULT_ENUM_UNKNOWN = 'Unknown'
    DEFAULT_PAGE_COUNT = 0
    DEFAULT_PAGE_TYPE = 'Story'
    DEFAULT_DOUBLE_PAGE = false
    DEFAULT_IMAGE_SIZE = 0

    # Validation methods
    module Validators
      # Validates YesNo enum values
      def self.validate_yes_no value
        return DEFAULT_ENUM_UNKNOWN if value.nil? || value.empty?

        raise Errors::InvalidEnumError.new('BlackAndWhite', value, YES_NO_VALUES) unless YES_NO_VALUES.include?(value)

        value
      end

      # Validates Manga enum values
      def self.validate_manga value
        return DEFAULT_ENUM_UNKNOWN if value.nil? || value.empty?

        raise Errors::InvalidEnumError.new('Manga', value, MANGA_VALUES) unless MANGA_VALUES.include?(value)

        value
      end

      # Validates AgeRating enum values
      def self.validate_age_rating value
        return DEFAULT_ENUM_UNKNOWN if value.nil? || value.empty?

        unless AGE_RATING_VALUES.include?(value)
          raise Errors::InvalidEnumError.new('AgeRating', value, AGE_RATING_VALUES)
        end

        value
      end

      # Validates ComicPageType enum values
      def self.validate_comic_page_type value
        return DEFAULT_PAGE_TYPE if value.nil? || value.empty?

        # Handle space-separated list of values
        values = value.split(/\s+/)
        values.each do |v|
          unless COMIC_PAGE_TYPE_VALUES.include?(v)
            raise Errors::InvalidEnumError.new('ComicPageType', v, COMIC_PAGE_TYPE_VALUES)
          end
        end

        value
      end

      # Validates CommunityRating decimal range (0.0 to 5.0)
      def self.validate_community_rating value
        return nil if value.nil? || value.empty?

        begin
          rating = Float(value)
          raise Errors::RangeError.new('CommunityRating', rating, 0.0, 5.0) if rating < 0.0 || rating > 5.0

          rating
        rescue ArgumentError
          raise Errors::TypeCoercionError.new('CommunityRating', value, 'Float')
        end
      end

      # Validates integer fields with range checking
      def self.validate_integer value, field_name = 'integer', default = DEFAULT_INTEGER
        return default if value.nil? || value.empty?

        begin
          Integer(value)
        rescue ArgumentError
          raise Errors::TypeCoercionError.new(field_name, value, 'Integer')
        end
      end

      # Validates date components (Year, Month, Day)
      def self.validate_year value
        return DEFAULT_INTEGER if value.nil? || value.empty?

        year = validate_integer(value, 'Year')
        if year != DEFAULT_INTEGER && (year < 1000 || year > 9999)
          raise Errors::RangeError.new('Year', year, 1000, 9999)
        end

        year
      end

      def self.validate_month value
        return DEFAULT_INTEGER if value.nil? || value.empty?

        month = validate_integer(value, 'Month')
        raise Errors::RangeError.new('Month', month, 1, 12) if month != DEFAULT_INTEGER && (month < 1 || month > 12)

        month
      end

      def self.validate_day value
        return DEFAULT_INTEGER if value.nil? || value.empty?

        day = validate_integer(value, 'Day')
        raise Errors::RangeError.new('Day', day, 1, 31) if day != DEFAULT_INTEGER && (day < 1 || day > 31)

        day
      end
    end

    # Helper methods for enum checks
    module Helpers
      def self.manga_right_to_left? value
        value == 'YesAndRightToLeft'
      end

      def self.yes_value? value
        %w[Yes YesAndRightToLeft].include?(value)
      end

      def self.no_value? value
        value == 'No'
      end

      def self.unknown_value? value
        value == 'Unknown' || value.nil? || value.empty?
      end
    end
  end
end
