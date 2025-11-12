require 'spec_helper'

RSpec.describe ComicInfo::FilenameCleaner do
  describe '#clean' do
    let(:cleaner)          { described_class.new tags: filename_tags }
    let(:cleaned_filename) { cleaner.clean old_filename }

    context 'when removing single tag' do
      let(:filename_tags) { %w[(Digital)] }
      let(:old_filename)  { 'Batman #1 (2021) (Digital).cbz' }
      let(:new_filename)  { 'Batman #1 (2021).cbz' }

      it 'removes Digital tag' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'when removing multiple tags' do
      let(:filename_tags) { %w[(Digital) (Zone-Empire) (c2c)] }
      let(:old_filename)  { 'Amazing Spider-Man #1 (2018) (Digital) (Zone-Empire) (c2c).cbr' }
      let(:new_filename)  { 'Amazing Spider-Man #1 (2018).cbr' }

      it 'removes Digital, Zone-Empire, and c2c tags' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'when normalizing whitespace' do
      let(:filename_tags) { %w[(Digital)] }
      let(:old_filename)  { '  Superman    #1   (2021)   (Digital)  .cbz' }
      let(:new_filename)  { 'Superman #1 (2021).cbz' }

      it 'normalizes multiple spaces and removes Digital tag' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with no tags to remove' do
      let(:filename_tags) { %w[(Digital) (Scan)] }
      let(:old_filename)  { 'X-Men #1 (2019).cbz' }
      let(:new_filename)  { 'X-Men #1 (2019).cbz' }

      it 'leaves filename unchanged when no matching tags' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with a partial tag match' do
      let(:filename_tags) { %w[(Digital)] }
      let(:old_filename)  { 'Flash #1 (2020) (Digital HD).cbz' }
      let(:new_filename)  { 'Flash #1 (2020) (Digital HD).cbz' }

      it 'does not remove partial matches' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with case sensitive tags' do
      let(:filename_tags) { %w[(Digital) (Scan)] }
      let(:old_filename)  { 'Wonder Woman #1 (2021) (digital).cbz' }
      let(:new_filename)  { 'Wonder Woman #1 (2021) (digital).cbz' }

      it 'does not remove different case tags' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with multiple spaces in a complex filename' do
      let(:filename_tags) { %w[(Digital) (Zone-Empire) (c2c)] }
      let(:old_filename)  { 'Justice League   #1  (2018)   (Digital)  (Zone-Empire)   (c2c)  .cbr' }
      let(:new_filename)  { 'Justice League #1 (2018).cbr' }

      it 'normalizes spaces and removes multiple tags' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with special characters in tags' do
      let(:filename_tags) { %w[(Digital-HD) (Zone-Empire)] }
      let(:old_filename)  { 'Deadpool #1 (2019) (Digital-HD) (Zone-Empire).cbz' }
      let(:new_filename)  { 'Deadpool #1 (2019).cbz' }

      it 'removes tags with hyphens and special characters' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with empty tags' do
      let(:filename_tags) { [] }
      let(:old_filename)  { '  Test   File  .cbz' }
      let(:new_filename)  { 'Test File.cbz' }

      it 'only normalizes whitespace' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with nil tags' do
      let(:filename_tags) { nil }
      let(:old_filename)  { '  Test         File         .cbz' }
      let(:new_filename)  { 'Test File.cbz' }

      it 'only normalizes whitespace' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'with different delimiter types' do
      let(:filename_tags) { ['[Digital]', '{Scan}', '(Zone-Empire)'] }
      let(:old_filename)  { 'Spider-Man #1 (2021) [Digital] {Scan} (Zone-Empire).cbz' }
      let(:new_filename)  { 'Spider-Man #1 (2021).cbz' }

      it 'removes tags with brackets, braces, and parentheses' do
        expect(cleaned_filename).to eq new_filename
      end
    end

    context 'when loading tags from file' do
      let(:old_filename) { '  Batman #1 (2021)    (Digital) [Scan] {c2c}.cbz' }
      let(:new_filename) { 'Batman #1 (2021).cbz' }
      let(:tags_file)    { fixture_path 'tags.txt' }

      let(:cleaner) { described_class.new tags_file: tags_file }

      it 'removes tags loaded from file' do
        expect(cleaned_filename).to eq new_filename
      end
    end
  end
end
