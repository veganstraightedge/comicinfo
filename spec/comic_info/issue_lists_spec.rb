RSpec.describe ComicInfo::Issue do
  describe '.joined_list' do
    it 'joins a list with commas' do
      expect(described_class.joined_list(%w[Action Adventure])).to eq 'Action, Adventure'
      expect(described_class.joined_list(['Saga'])).to eq 'Saga'
    end

    it 'is nil when there is nothing to write' do
      expect(described_class.joined_list([])).to be_nil
      expect(described_class.joined_list(['', '  '])).to be_nil
    end

    it 'trims, and drops empty values and repeats' do
      expect(described_class.joined_list(['  Action ', '', 'Adventure', 'Action'])).to eq 'Action, Adventure'
    end

    it 'replaces commas inside a value' do
      expect(described_class.joined_list(['Peter Parker, Jr.'])).to eq 'Peter Parker Jr.'
      expect(described_class.joined_list(['a,b'])).to eq 'a b'
    end

    it 'reads back as the same list' do
      issue  = load_fixture 'valid_complete.xml'
      joined = described_class.joined_list issue.genres
      xml    = "<ComicInfo><Genre>#{joined}</Genre></ComicInfo>"

      expect(ComicInfo.load(xml).genres).to eq issue.genres
    end
  end

  describe '#web_links' do
    it 'keeps every entry as text' do
      issue = load_fixture 'lists/messy_web.xml'

      expect(issue.web_links).to eq %w[https://example.com not-a-url https://example.org]
    end

    it 'is every link of the web field' do
      issue = load_fixture 'valid_complete.xml'

      expect(issue.web_links).to eq %w[
        https://marvel.com/comics/issue/12345
        https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/
      ]
    end

    it 'is empty without a web field' do
      expect(load_fixture('valid_minimal.xml').web_links).to be_empty
    end
  end

  describe '.joined_web' do
    it 'joins links with spaces, dropping empty values and repeats' do
      links = [' https://example.com', '', 'https://example.org', 'https://example.com']

      expect(described_class.joined_web(links)).to eq 'https://example.com https://example.org'
    end

    it 'is nil when there is nothing to write' do
      expect(described_class.joined_web([])).to be_nil
    end

    it 'splits an entry with spaces in it' do
      expect(described_class.joined_web(['https://example.com https://example.org'])).to eq 'https://example.com https://example.org'
    end
  end
end
