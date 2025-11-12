module ComicInfo
  class FilenameCleaner
    def initialize tags: [], tags_file: nil
      @tags = Array tags
      @tags = load_tags_from_file tags_file if tags_file
    end

    def clean filename
      filename_extension = File.extname  filename
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

    private

    def load_tags_from_file file_path
      File.readlines(file_path, chomp: true).reject(&:empty?)
    end
  end
end
