require_relative 'comicinfo/version'

module ComicInfo
  class Error < StandardError; end

  autoload :Issue, 'comicinfo/issue'
  autoload :Page, 'comicinfo/page'
  autoload :Enums, 'comicinfo/enums'
  autoload :Errors, 'comicinfo/errors'

  # Convenience method for loading ComicInfo files
  def self.load file_path_or_xml_string
    Issue.load(file_path_or_xml_string)
  end
end
