module ComicInfo
  class FilenameCleaner
    def initialize tags: []
      @tags = Array(tags)
    end

    def clean filename
      result = filename.dup

      @tags.each do |tag|
        # Remove tags with their delimiters (parentheses, brackets, braces, etc.)
        result = result.gsub(/\s*#{Regexp.escape(tag)}/, '')
      end

      # Clean up multiple spaces and trim, but preserve single space before extension
      result = result.gsub(/\s+/, ' ').strip

      # Remove space before file extension
      result.gsub(/\s+\.([^.]+)$/, '.\1')
    end
  end
end
