# frozen_string_literal: true

require_relative 'comicinfo/version'

module ComicInfo
  class Error < StandardError; end

  autoload :ComicInfo, 'comicinfo/comic_info'
  autoload :ComicPageInfo, 'comicinfo/page_info'
  autoload :Enums, 'comicinfo/enums'
  autoload :Errors, 'comicinfo/errors'

  # Convenience method for loading ComicInfo files
  def self.load file_path_or_xml_string
    ComicInfo.load(file_path_or_xml_string)
  end
end
