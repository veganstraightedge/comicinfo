require 'spec_helper'

RSpec.describe ComicInfo::FilenameCleaner do
  describe '#clean' do
    context 'single tag removal' do
      it 'removes Digital tag' do
        cleaner = described_class.new(tags: ['Digital'])

        expect(cleaner.clean('Batman #1 (2021) (Digital).cbz')).to eq('Batman #1 (2021).cbz')
      end
    end

    context 'multiple tag removal' do
      it 'removes Digital, Zone-Empire, and c2c tags' do
        cleaner = described_class.new(tags: %w[Digital Zone-Empire c2c])

        expect(cleaner.clean('Amazing Spider-Man #1 (2018) (Digital) (Zone-Empire) (c2c).cbr')).to eq('Amazing Spider-Man #1 (2018).cbr')
      end
    end

    context 'whitespace normalization' do
      it 'normalizes multiple spaces and removes Digital tag' do
        cleaner = described_class.new(tags: ['Digital'])

        expect(cleaner.clean('  Superman    #1   (2021)   (Digital)  .cbz')).to eq('Superman #1 (2021).cbz')
      end
    end

    context 'no tags to remove' do
      it 'leaves filename unchanged when no matching tags' do
        cleaner = described_class.new(tags: %w[Digital Scan])

        expect(cleaner.clean('X-Men #1 (2019).cbz')).to eq('X-Men #1 (2019).cbz')
      end
    end

    context 'partial tag match' do
      it 'does not remove partial matches' do
        cleaner = described_class.new(tags: ['Digital'])

        expect(cleaner.clean('Flash #1 (2020) (Digital HD).cbz')).to eq('Flash #1 (2020) (Digital HD).cbz')
      end
    end

    context 'case sensitive tags' do
      it 'does not remove different case tags' do
        cleaner = described_class.new(tags: ['Digital'])

        expect(cleaner.clean('Wonder Woman #1 (2021) (digital).cbz')).to eq('Wonder Woman #1 (2021) (digital).cbz')
      end
    end

    context 'complex filename with multiple spaces' do
      it 'normalizes spaces and removes multiple tags' do
        cleaner = described_class.new(tags: %w[Digital Zone-Empire c2c])

        expect(cleaner.clean('Justice League   #1  (2018)   (Digital)  (Zone-Empire)   (c2c)  .cbr')).to eq('Justice League #1 (2018).cbr')
      end
    end

    context 'special characters in tags' do
      it 'removes tags with hyphens and special characters' do
        cleaner = described_class.new(tags: %w[Digital-HD Zone-Empire])

        expect(cleaner.clean('Deadpool #1 (2019) (Digital-HD) (Zone-Empire).cbz')).to eq('Deadpool #1 (2019).cbz')
      end
    end

    context 'with empty tags' do
      it 'only normalizes whitespace' do
        cleaner = described_class.new(tags: [])

        expect(cleaner.clean('  Test   File  .cbz')).to eq('Test File.cbz')
      end
    end
  end
end
