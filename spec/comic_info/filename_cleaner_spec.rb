require 'spec_helper'

RSpec.describe ComicInfo::FilenameCleaner do
  describe '#clean' do
    let(:subject) { described_class.new(tags: tags).clean(old_filename) }

    context 'single tag removal' do
      let(:tags)         { ['Digital'] }
      let(:old_filename) { 'Batman #1 (2021) (Digital).cbz' }
      let(:new_filename) { 'Batman #1 (2021).cbz' }

      it 'removes Digital tag' do
        expect(subject).to eq new_filename
      end
    end

    context 'multiple tag removal' do
      let(:tags)         { %w[Digital Zone-Empire c2c] }
      let(:old_filename) { 'Amazing Spider-Man #1 (2018) (Digital) (Zone-Empire) (c2c).cbr' }
      let(:new_filename) { 'Amazing Spider-Man #1 (2018).cbr' }

      it 'removes Digital, Zone-Empire, and c2c tags' do
        expect(subject).to eq new_filename
      end
    end

    context 'whitespace normalization' do
      let(:tags)         { %w[Digital] }
      let(:old_filename) { '  Superman    #1   (2021)   (Digital)  .cbz' }
      let(:new_filename) { 'Superman #1 (2021).cbz' }

      it 'normalizes multiple spaces and removes Digital tag' do
        expect(subject).to eq new_filename
      end
    end

    context 'no tags to remove' do
      let(:tags)         { %w[Digital Scan] }
      let(:old_filename) { 'X-Men #1 (2019).cbz' }
      let(:new_filename) { 'X-Men #1 (2019).cbz' }

      it 'leaves filename unchanged when no matching tags' do
        expect(subject).to eq new_filename
      end
    end

    context 'partial tag match' do
      let(:tags)         { %w[Digital] }
      let(:old_filename) { 'Flash #1 (2020) (Digital HD).cbz' }
      let(:new_filename) { 'Flash #1 (2020) (Digital HD).cbz' }

      it 'does not remove partial matches' do
        expect(subject).to eq new_filename
      end
    end

    context 'case sensitive tags' do
      let(:tags)         { %w[Digital Scan] }
      let(:old_filename) { 'Wonder Woman #1 (2021) (digital).cbz' }
      let(:new_filename) { 'Wonder Woman #1 (2021) (digital).cbz' }

      it 'does not remove different case tags' do
        expect(subject).to eq new_filename
      end
    end

    context 'complex filename with multiple spaces' do
      let(:tags)         { %w[Digital Zone-Empire c2c] }
      let(:old_filename) { 'Justice League   #1  (2018)   (Digital)  (Zone-Empire)   (c2c)  .cbr' }
      let(:new_filename) { 'Justice League #1 (2018).cbr' }

      it 'normalizes spaces and removes multiple tags' do
        expect(subject).to eq new_filename
      end
    end

    context 'special characters in tags' do
      let(:tags)         { %w[Digital-HD Zone-Empire] }
      let(:old_filename) { 'Deadpool #1 (2019) (Digital-HD) (Zone-Empire).cbz' }
      let(:new_filename) { 'Deadpool #1 (2019).cbz' }

      it 'removes tags with hyphens and special characters' do
        expect(subject).to eq new_filename
      end
    end

    context 'with empty tags' do
      let(:tags)         { [] }
      let(:old_filename) { '  Test   File  .cbz' }
      let(:new_filename) { 'Test File.cbz' }

      it 'only normalizes whitespace' do
        expect(subject).to eq new_filename
      end
    end
  end
end
