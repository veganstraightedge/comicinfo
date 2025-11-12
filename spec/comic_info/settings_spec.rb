require 'spec_helper'
require 'yaml'
require 'tmpdir'

RSpec.describe ComicInfo::Settings do
  let(:temp_dir)              { Dir.mktmpdir 'longbox_test_' }
  let(:settings_fixture_path) { fixture_path 'settings.yaml' }
  let(:test_settings_path)    { File.join temp_dir, 'settings.yaml' }
  let(:custom_settings_path)  { File.join temp_dir, 'custom_settings.yaml' }

  after { FileUtils.rm_rf temp_dir } # Clean up test directory

  describe '.create' do
    subject(:filename_tags) { settings['filename_tags'] }

    let(:settings_path) { custom_settings_path }
    let(:settings) { YAML.load_file settings_path }

    before { described_class.create settings_path }

    context 'with default settings' do
      let(:settings_path) { test_settings_path }

      it 'creates settings file with empty filename_tags' do
        expect(File).to exist test_settings_path
        expect(filename_tags).to eq []
      end
    end

    context 'with a custom path' do
      it 'creates settings file at custom path' do
        expect(File).to exist custom_settings_path
        expect(filename_tags).to eq []
      end
    end

    context 'when creating settings file' do
      let(:settings) { described_class.create settings_path }

      it 'returns the path to the created settings file' do
        expect(settings).to eq custom_settings_path
      end
    end
  end

  describe '.load' do
    subject(:filename_tags) { settings.filename_tags }

    let(:settings) { described_class.load settings_path }

    context 'when loading settings from a fixture file' do
      let(:settings_path) { settings_fixture_path }

      it 'loads settings from test fixture' do
        expect(filename_tags).to eq ['(Digital)', '[Scan]', '{c2c}', '(Zone-Empire)', '(Digital-HD)']
      end
    end

    context 'when loading settings from a custom file' do
      let(:settings_path) { custom_settings_path }

      before { described_class.create custom_settings_path }

      it 'loads settings from custom path' do
        expect(filename_tags).to be_empty
      end
    end

    context 'when loading a nonexistent settings file' do
      let(:settings_path) { '/nonexistent/path.yaml' }

      it 'returns nil when settings file does not exist' do
        expect(settings).to be_nil
      end
    end
  end

  describe '#filename_tags' do
    subject(:filename_tags) { settings.filename_tags }

    let(:settings_path) { settings_fixture_path }
    let(:settings) { described_class.load settings_path }

    it 'returns the filename tags from fixture settings' do
      expect(filename_tags).to eq ['(Digital)', '[Scan]', '{c2c}', '(Zone-Empire)', '(Digital-HD)']
    end
  end

  describe '#add_filename_tag' do
    subject(:filename_tags) { settings.filename_tags }

    let(:settings) { described_class.load settings_path }

    before { described_class.create settings_path }

    context 'with an existing tag in settings file' do
      let(:settings_path) { test_settings_path }

      before { settings.add_filename_tag '(Digital)' }

      it 'adds a new filename tag' do
        expect(filename_tags).to eq ['(Digital)']
      end
    end

    context 'with an existing tag' do
      let(:settings_path) { custom_settings_path }

      before do
        settings.add_filename_tag '(Digital)'
        settings.add_filename_tag '(Digital)'
      end

      it 'does not add duplicate tags' do
        expect(filename_tags).to eq ['(Digital)']
      end
    end
  end

  describe '#remove_filename_tag' do
    subject(:filename_tags) { settings.filename_tags }

    let(:settings) { described_class.load settings_path }
    let(:settings_path) { custom_settings_path }

    before { described_class.create settings_path }

    context 'with an existing tag' do
      before do
        settings.add_filename_tag '(Digital)'
        settings.add_filename_tag '[Scan]'
        settings.remove_filename_tag('(Digital)')
      end

      it 'removes an existing filename tag' do
        expect(filename_tags).to eq ['[Scan]']
      end
    end

    context 'with no conflicting tags' do
      before do
        settings.add_filename_tag '[Scan]'
        settings.remove_filename_tag '(Digital)'
      end

      it 'does nothing when tag does not exist' do
        expect(filename_tags).to eq ['[Scan]']
      end
    end
  end

  describe '#save' do
    subject(:filename_tags) { reloaded_settings['filename_tags'] }

    let(:settings_path) { test_settings_path }
    let(:settings) { described_class.load settings_path }
    let(:reloaded_settings) { YAML.load_file test_settings_path }

    before do
      described_class.create settings_path
      settings.add_filename_tag '(Digital)'
      settings.save
    end

    it 'saves changes to the settings file' do
      expect(filename_tags).to eq ['(Digital)']
    end
  end
end
