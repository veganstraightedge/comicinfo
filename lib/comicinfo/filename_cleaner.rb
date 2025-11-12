module ComicInfo
  class FilenameCleaner
    def initialize tags: [], tags_file: nil, tags_env: nil
      @tags = if tags_env
                load_tags_from_env_var tags_env
              elsif tags_file
                load_tags_from_file tags_file
              else
                Array tags
              end
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
      tag_lines = File.readlines file_path, chomp: true
      tag_lines.reject &:empty?
    end

    def load_tags_from_env_var env_var_name
      env_var_value = ENV.fetch env_var_name, nil
      return [] unless env_var_value

      tags = env_var_value.split ','
      tags.map! &:strip
      tags.reject! &:empty?

      tags
    end
  end
end
