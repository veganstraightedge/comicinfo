# frozen_string_literal: true

require_relative 'enums'
require_relative 'errors'

module ComicInfo
  # Represents a single page in a comic book with metadata
  # Maps to ComicPageInfo type in the ComicInfo XSD schema
  class Page
    # Page attributes from XSD schema
    attr_reader :image, :type, :double_page, :image_size, :key, :bookmark, :image_width, :image_height

    def initialize attributes = {}
      @image = parse_image(attributes['Image'] || attributes[:image])
      @type = Enums::Validators.validate_comic_page_type(attributes['Type'] || attributes[:type])
      @double_page = parse_boolean(attributes['DoublePage'] || attributes[:double_page])
      @image_size = parse_image_size(attributes['ImageSize'] || attributes[:image_size])
      @key = (attributes['Key'] || attributes[:key] || Enums::DEFAULT_STRING).to_s
      @bookmark = (attributes['Bookmark'] || attributes[:bookmark] || Enums::DEFAULT_STRING).to_s
      @image_width = parse_image_dimension(attributes['ImageWidth'] || attributes[:image_width], 'ImageWidth')
      @image_height = parse_image_dimension(attributes['ImageHeight'] || attributes[:image_height], 'ImageHeight')
    end

    # Check if this page is a cover page
    def cover?
      @type == 'FrontCover' || @type == 'BackCover' || @type == 'InnerCover'
    end

    # Check if this page is a story page
    def story?
      @type == 'Story'
    end

    # Check if this page should be deleted/hidden
    def deleted?
      @type == 'Deleted'
    end

    # Check if this is a double-page spread
    def double_page?
      @double_page
    end

    # Get page types as an array (handles space-separated values)
    def types
      @type.split(/\s+/)
    end

    # Check if page has a specific type
    def include_type? type
      types.include?(type)
    end

    # Get image dimensions as a hash
    def dimensions
      {
        width:  @image_width == Enums::DEFAULT_INTEGER ? nil : @image_width,
        height: @image_height == Enums::DEFAULT_INTEGER ? nil : @image_height
      }
    end

    # Check if image dimensions are available
    def dimensions_available?
      @image_width != Enums::DEFAULT_INTEGER && @image_height != Enums::DEFAULT_INTEGER
    end

    # Get aspect ratio if dimensions are available
    def aspect_ratio
      return nil unless dimensions_available? && @image_height != 0

      @image_width.to_f / @image_height
    end

    # Check if this page has a bookmark
    def bookmarked?
      !@bookmark.empty?
    end

    # Convert to hash representation
    def to_h
      {
        image:        @image,
        type:         @type,
        double_page:  @double_page,
        image_size:   @image_size,
        key:          @key,
        bookmark:     @bookmark,
        image_width:  @image_width,
        image_height: @image_height
      }
    end

    # Convert to XML attributes hash (for XML generation)
    def to_xml_attributes
      attrs = { 'Image' => @image.to_s }
      attrs['Type'] = @type unless @type == Enums::DEFAULT_PAGE_TYPE
      attrs['DoublePage'] = @double_page.to_s unless @double_page == Enums::DEFAULT_DOUBLE_PAGE
      attrs['ImageSize'] = @image_size.to_s unless @image_size == Enums::DEFAULT_IMAGE_SIZE
      attrs['Key'] = @key unless @key.empty?
      attrs['Bookmark'] = @bookmark unless @bookmark.empty?
      attrs['ImageWidth'] = @image_width.to_s unless @image_width == Enums::DEFAULT_INTEGER
      attrs['ImageHeight'] = @image_height.to_s unless @image_height == Enums::DEFAULT_INTEGER
      attrs
    end

    # String representation
    def to_s
      parts = ["Page #{@image}"]
      parts << "Type: #{@type}" unless @type == Enums::DEFAULT_PAGE_TYPE
      parts << 'Double' if @double_page
      parts << "Bookmark: #{@bookmark}" unless @bookmark.empty?
      parts.join(', ')
    end

    # Detailed inspection
    def inspect
      "#<ComicInfo::Page #{self}>"
    end

    # Equality comparison
    def == other
      return false unless other.is_a?(Page)

      @image == other.image &&
        @type == other.type &&
        @double_page == other.double_page &&
        @image_size == other.image_size &&
        @key == other.key &&
        @bookmark == other.bookmark &&
        @image_width == other.image_width &&
        @image_height == other.image_height
    end

    alias eql? ==

    def hash
      [@image, @type, @double_page, @image_size, @key, @bookmark, @image_width, @image_height].hash
    end

    private

    def parse_image value
      raise Errors::SchemaError, 'Image attribute is required for Page' if value.nil? || value.to_s.empty?

      begin
        Integer(value)
      rescue ArgumentError
        raise Errors::TypeCoercionError.new('Image', value, 'Integer')
      end
    end

    def parse_boolean value
      case value.to_s.downcase
      when 'true', '1', 'yes'
        true
      when 'false', '0', 'no', ''
        false
      else
        raise Errors::TypeCoercionError.new('DoublePage', value, 'Boolean')
      end
    end

    def parse_image_size value
      return Enums::DEFAULT_IMAGE_SIZE if value.nil? || value.to_s.empty?

      begin
        size = Integer(value)
        size.negative? ? Enums::DEFAULT_IMAGE_SIZE : size
      rescue ArgumentError
        raise Errors::TypeCoercionError.new('ImageSize', value, 'Integer')
      end
    end

    def parse_image_dimension value, field_name
      return Enums::DEFAULT_INTEGER if value.nil? || value.to_s.empty?

      begin
        Integer(value)
      rescue ArgumentError
        raise Errors::TypeCoercionError.new(field_name, value, 'Integer')
      end
    end
  end
end
