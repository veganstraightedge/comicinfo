require 'yaml'
require 'fileutils'

module ComicInfo
  class Settings
    DEFAULT_SETTINGS_PATH = File.expand_path('~/.longbox/settings.yaml').freeze

    attr_reader :filename_tags, :settings_path

    def initialize data, settings_path
      @data = data
      @settings_path = settings_path
      @filename_tags = @data['filename_tags'] || []
    end

    def self.create path = nil
      settings_path = path || DEFAULT_SETTINGS_PATH
      settings_dir = File.dirname(settings_path)

      FileUtils.mkdir_p(settings_dir)

      default_data = { 'filename_tags' => [] }
      File.write(settings_path, YAML.dump(default_data))

      settings_path
    end

    def self.load path = nil
      settings_path = path || DEFAULT_SETTINGS_PATH
      return nil unless File.exist?(settings_path)

      data = YAML.load_file(settings_path)
      new(data, settings_path)
    end

    def add_filename_tag tag
      @filename_tags << tag unless @filename_tags.include?(tag)
    end

    def remove_filename_tag tag
      @filename_tags.delete(tag)
    end

    def save
      @data['filename_tags'] = @filename_tags
      File.write(@settings_path, YAML.dump(@data))
    end
  end
end
