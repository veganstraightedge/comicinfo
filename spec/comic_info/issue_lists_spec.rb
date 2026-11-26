RSpec.describe ComicInfo::Issue do
  let(:issue) { load_fixture 'valid_minimal.xml' }

  describe '#with_genres' do
    it 'joins the list with commas' do
      updated = issue.with_genres %w[Action Adventure]

      expect(updated.genres_raw_data).to eq 'Action, Adventure'
      expect(updated.genres).to eq %w[Action Adventure]
    end

    it 'removes the field for an empty list' do
      complete = load_fixture 'valid_complete.xml'

      expect(complete.with_genres([]).genres).to be_empty
      expect(complete.with_genres(['', '  ']).to_xml).not_to include '<Genre>'
    end

    it 'changes nothing else' do
      complete = load_fixture 'valid_complete.xml'
      restored = complete.with_genres(complete.genres.reverse).with_genres(complete.genres)

      expect(restored.to_xml).to eq complete.to_xml
    end

    it 'leaves the issue it was called on as it was' do
      issue.with_genres ['Action']

      expect(issue.genres).to be_empty
    end
  end

  describe 'the other list setters' do
    it 'set their own list' do
      expect(issue.with_characters(%w[Alana Marko]).characters_raw_data).to eq 'Alana, Marko'
      expect(issue.with_locations(%w[Landfall Wreath]).locations_raw_data).to eq 'Landfall, Wreath'
      expect(issue.with_teams(['The Will']).teams_raw_data).to eq 'The Will'
    end

    it 'trim, and drop empty values and repeats' do
      updated = issue.with_characters ['  Alana ', '', 'Marko', 'Alana']

      expect(updated.characters_raw_data).to eq 'Alana, Marko'
    end

    it 'replace commas inside a value' do
      expect(issue.with_characters(['Peter Parker, Jr.']).characters_raw_data).to eq 'Peter Parker Jr.'
      expect(issue.with_characters(['a,b']).characters).to eq ['a b']
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
      expect(issue.web_links).to be_empty
    end
  end

  describe '#with_web_links' do
    it 'joins links with spaces, dropping empty values and repeats' do
      links = [' https://example.com', '', 'https://example.org', 'https://example.com']

      expect(issue.with_web_links(links).web).to eq 'https://example.com https://example.org'
    end

    it 'removes the field for an empty list' do
      expect(issue.with_web_links([]).to_xml).not_to include '<Web>'
    end

    it 'splits a link with spaces in it' do
      updated = issue.with_web_links ['https://example.com https://example.org']

      expect(updated.web_links).to eq %w[https://example.com https://example.org]
    end
  end
end
