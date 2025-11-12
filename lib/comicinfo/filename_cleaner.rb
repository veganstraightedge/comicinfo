module ComicInfo
  class FilenameCleaner
    def initialize tags: []
      @tags = Array tags
    end

    def clean filename
      filename_extension = File.extname filename
      filename_base      = File.basename filename, filename_extension

      # Remove tags from filename
      @tags.each { filename_base.gsub! it, '' }

      # Remove line breaks
      filename_base.chomp!

      # Remove leading and trailing blank spaces
      filename_base.strip!

      # Remove multiple blank spaces
      filename_base.squeeze! ' '

      # Put the filename back together
      filename_base + filename_extension
    end
  end
end
