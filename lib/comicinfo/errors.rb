# frozen_string_literal: true

module ComicInfo
  module Errors
    # Base error class for all ComicInfo-related errors
    class ComicInfoError < StandardError; end

    # Error raised when XML parsing fails
    class ParseError < ComicInfoError
      def initialize message = 'Failed to parse XML'
        super
      end
    end

    # Error raised when file cannot be read
    class FileError < ComicInfoError
      def initialize message = 'Failed to read file'
        super
      end
    end

    # Error raised when enum values are invalid
    class InvalidEnumError < ComicInfoError
      attr_reader :field, :value, :valid_values

      def initialize field, value, valid_values
        @field = field
        @value = value
        @valid_values = valid_values
        super("Invalid value '#{value}' for field '#{field}'. Valid values are: #{valid_values.join(', ')}")
      end
    end

    # Error raised when numeric values are out of range
    class RangeError < ComicInfoError
      attr_reader :field, :value, :min, :max

      def initialize field, value, min, max
        @field = field
        @value = value
        @min = min
        @max = max
        super("Value '#{value}' for field '#{field}' is out of range (#{min}..#{max})")
      end
    end

    # Error raised when type coercion fails
    class TypeCoercionError < ComicInfoError
      attr_reader :field, :value, :expected_type

      def initialize field, value, expected_type
        @field = field
        @value = value
        @expected_type = expected_type
        super("Cannot convert value '#{value}' for field '#{field}' to #{expected_type}")
      end
    end

    # Error raised when schema validation fails
    class SchemaError < ComicInfoError
      def initialize message = 'Schema validation failed'
        super
      end
    end
  end
end
