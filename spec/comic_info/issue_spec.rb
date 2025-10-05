# frozen_string_literal: true

RSpec.describe ComicInfo::Issue do
  describe '.load' do
    context 'with valid file path' do
      it 'loads a minimal ComicInfo.xml file' do
        comic = load_fixture('valid_minimal.xml')

        expect(comic).to be_a(described_class)
        expect(comic.title).to eq('Minimal Comic')
        expect(comic.series).to eq('Test Series')
        expect(comic.number).to eq('1')
      end

      it 'loads a complete ComicInfo.xml file' do
        comic = load_fixture('valid_complete.xml')

        expect(comic).to be_a(described_class)
        expect(comic.title).to eq('The Amazing Spider-Man')
        expect(comic.series).to eq('The Amazing Spider-Man')
        expect(comic.count).to eq(600)
        expect(comic.volume).to eq(3)
        expect(comic.community_rating).to eq(4.25)
      end

      it "raises FileError when file doesn't exist" do
        expect do
          described_class.load('nonexistent.xml')
        end.to raise_error(ComicInfo::Errors::FileError)
      end
    end

    context 'with XML string' do
      it 'loads from XML string content' do
        xml_content = fixture_file('valid_minimal.xml')
        comic = described_class.load(xml_content)

        expect(comic).to be_a(described_class)
        expect(comic.title).to eq('Minimal Comic')
      end

      it 'raises ParseError with malformed XML' do
        malformed_xml = '<ComicInfo><Title>Test</ComicInfo>'
        expect do
          described_class.load(malformed_xml)
        end.to raise_error(ComicInfo::Errors::ParseError)
      end
    end
  end

  describe '.new' do
    it 'creates instance from XML string' do
      xml_content = fixture_file('valid_minimal.xml')
      comic = described_class.new(xml_content)

      expect(comic).to be_a(described_class)
      expect(comic.title).to eq('Minimal Comic')
    end

    it 'raises ParseError with invalid XML' do
      expect do
        described_class.new('<invalid>xml')
      end.to raise_error(ComicInfo::Errors::ParseError)
    end
  end

  describe 'basic string fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns title' do
      expect(complete_comic.title).to eq('The Amazing Spider-Man')
    end

    it 'returns series' do
      expect(complete_comic.series).to eq('The Amazing Spider-Man')
    end

    it 'returns number as string' do
      expect(complete_comic.number).to eq('1')
    end

    it 'returns summary' do
      expect(complete_comic.summary).to include('radioactive spider')
    end

    it 'returns notes' do
      expect(complete_comic.notes).to eq('Scanned by ComicTagger v1.0')
    end

    it 'returns alternate series' do
      expect(complete_comic.alternate_series).to eq('Civil War')
    end

    it 'returns alternate number' do
      expect(complete_comic.alternate_number).to eq('2')
    end
  end

  describe 'creator fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns writer' do
      expect(complete_comic.writer).to eq('Dan Slott, Christos Gage')
    end

    it 'returns penciller' do
      expect(complete_comic.penciller).to eq('Ryan Ottley')
    end

    it 'returns inker' do
      expect(complete_comic.inker).to eq('Cliff Rathburn')
    end

    it 'returns colorist' do
      expect(complete_comic.colorist).to eq('Laura Martin')
    end

    it 'returns letterer' do
      expect(complete_comic.letterer).to eq('Joe Caramagna')
    end

    it 'returns cover artist' do
      expect(complete_comic.cover_artist).to eq('Ryan Ottley')
    end

    it 'returns editor' do
      expect(complete_comic.editor).to eq('Nick Lowe')
    end

    it 'returns translator' do
      expect(complete_comic.translator).to eq('John Smith')
    end
  end

  describe 'publication fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns publisher' do
      expect(complete_comic.publisher).to eq('Marvel Comics')
    end

    it 'returns imprint' do
      expect(complete_comic.imprint).to eq('Marvel')
    end

    it 'returns genre' do
      expect(complete_comic.genre).to eq('Superhero, Action, Adventure')
    end

    it 'returns web' do
      expect(complete_comic.web).to eq('https://marvel.com/comics/issue/12345 https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/')
    end

    it 'returns language ISO' do
      expect(complete_comic.language_iso).to eq('en-US')
    end

    it 'returns format' do
      expect(complete_comic.format).to eq('Digital')
    end
  end

  describe 'integer fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns count as integer' do
      expect(complete_comic.count).to eq(600)
    end

    it 'returns volume as integer' do
      expect(complete_comic.volume).to eq(3)
    end

    it 'returns alternate count as integer' do
      expect(complete_comic.alternate_count).to eq(7)
    end

    it 'returns year as integer' do
      expect(complete_comic.year).to eq(2018)
    end

    it 'returns month as integer' do
      expect(complete_comic.month).to eq(3)
    end

    it 'returns day as integer' do
      expect(complete_comic.day).to eq(15)
    end

    it 'returns page count as integer' do
      expect(complete_comic.page_count).to eq(20)
    end
  end

  describe 'enum fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns black and white enum' do
      expect(complete_comic.black_and_white).to eq('No')
    end

    it 'returns manga enum' do
      expect(complete_comic.manga).to eq('No')
    end

    it 'returns age rating enum' do
      expect(complete_comic.age_rating).to eq('Teen')
    end

    context 'with invalid enum values' do
      it 'raises InvalidEnumError for invalid BlackAndWhite' do
        expect do
          xml_with_invalid_enum = <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <ComicInfo>
              <BlackAndWhite>Maybe</BlackAndWhite>
            </ComicInfo>
          XML
          described_class.new(xml_with_invalid_enum)
        end.to raise_error(ComicInfo::Errors::InvalidEnumError)
      end
    end
  end

  describe 'decimal fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns community rating as float' do
      expect(complete_comic.community_rating).to eq(4.25)
      expect(complete_comic.community_rating).to be_a(Float)
    end

    context 'with invalid rating values' do
      it 'raises RangeError for rating above 5.0' do
        expect do
          xml_with_invalid_rating = <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <ComicInfo>
              <CommunityRating>6.0</CommunityRating>
            </ComicInfo>
          XML
          described_class.new(xml_with_invalid_rating)
        end.to raise_error(ComicInfo::Errors::RangeError)
      end

      it 'raises RangeError for negative rating' do
        expect do
          xml_with_invalid_rating = <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <ComicInfo>
              <CommunityRating>-1.0</CommunityRating>
            </ComicInfo>
          XML
          described_class.new(xml_with_invalid_rating)
        end.to raise_error(ComicInfo::Errors::RangeError)
      end
    end
  end

  describe 'multi-value fields' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    describe 'singular methods (return strings)' do
      it 'returns character as comma-separated string' do
        expect(complete_comic.character).to eq('Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May')
      end

      it 'returns team as comma-separated string' do
        expect(complete_comic.team).to eq('Avengers')
      end

      it 'returns location as comma-separated string' do
        expect(complete_comic.location).to eq('New York City, Manhattan, Queens')
      end

      it 'returns story_arc as comma-separated string' do
        expect(complete_comic.story_arc).to eq('Brand New Day, Spider-Island')
      end

      it 'returns story_arc_number as comma-separated string' do
        expect(complete_comic.story_arc_number).to eq('1, 5')
      end

      it 'returns genre as comma-separated string' do
        expect(complete_comic.genre).to eq('Superhero, Action, Adventure')
      end

      it 'returns web as space-separated string' do
        expect(complete_comic.web).to eq('https://marvel.com/comics/issue/12345 https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/')
      end
    end

    describe 'plural methods (return arrays)' do
      it 'returns characters as array' do
        expect(complete_comic.characters).to eq(['Spider-Man', 'Peter Parker', 'J. Jonah Jameson', 'Aunt May'])
      end

      it 'returns teams as array' do
        expect(complete_comic.teams).to eq(['Avengers'])
      end

      it 'returns locations as array' do
        expect(complete_comic.locations).to eq(['New York City', 'Manhattan', 'Queens'])
      end

      it 'returns story_arcs as array' do
        expect(complete_comic.story_arcs).to eq(['Brand New Day', 'Spider-Island'])
      end

      it 'returns story_arc_numbers as array' do
        expect(complete_comic.story_arc_numbers).to eq(%w[1 5])
      end

      it 'returns genres as array' do
        expect(complete_comic.genres).to eq(%w[Superhero Action Adventure])
      end

      it 'returns web_urls as array' do
        expect(complete_comic.web_urls).to eq(['https://marvel.com/comics/issue/12345', 'https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/'])
      end
    end
  end

  describe 'pages array' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    it 'returns array of ComicPageInfo objects' do
      expect(complete_comic.pages).to be_an(Array)
      expect(complete_comic.pages.length).to eq(12)
      expect(complete_comic.pages.first).to be_a(ComicInfo::Page)
    end

    it 'parses page attributes correctly' do
      first_page = complete_comic.pages.first
      expect(first_page.image).to eq(0)
      expect(first_page.type).to eq('FrontCover')
      expect(first_page.double_page).to be false
      expect(first_page.image_size).to eq(1_024_000)
      expect(first_page.image_width).to eq(1600)
      expect(first_page.image_height).to eq(2400)
    end

    it 'handles double-page spreads' do
      double_page = complete_comic.pages[3] # Image="3" is marked as DoublePage="true"
      expect(double_page.double_page?).to be true
      expect(double_page.image_width).to eq(3200) # Double width
    end
  end

  describe 'default values' do
    let(:minimal_comic) { load_fixture('valid_minimal.xml') }

    it 'returns default integer value for missing fields' do
      expect(minimal_comic.count).to eq(-1)
      expect(minimal_comic.volume).to eq(-1)
      expect(minimal_comic.year).to eq(-1)
    end

    it 'returns default string value for missing fields' do
      expect(minimal_comic.summary).to eq('')
      expect(minimal_comic.notes).to eq('')
      expect(minimal_comic.publisher).to eq('')
    end

    it 'returns default enum value for missing fields' do
      expect(minimal_comic.black_and_white).to eq('Unknown')
      expect(minimal_comic.manga).to eq('Unknown')
      expect(minimal_comic.age_rating).to eq('Unknown')
    end
  end

  describe 'edge cases' do
    context 'with empty fields' do
      let(:empty_comic) { load_fixture('edge_cases/empty_fields.xml') }

      it 'handles empty string fields' do
        expect(empty_comic.title).to eq('')
        expect(empty_comic.series).to eq('')
      end

      it 'handles empty integer fields' do
        expect(empty_comic.count).to eq(-1)
        expect(empty_comic.year).to eq(-1)
      end

      it 'handles empty enum fields' do
        expect(empty_comic.black_and_white).to eq('Unknown')
      end
    end

    context 'with Unicode and special characters' do
      let(:unicode_comic) { load_fixture('edge_cases/unicode_special_chars.xml') }

      it 'preserves Unicode characters in title' do
        expect(unicode_comic.title).to include('漫画')
        expect(unicode_comic.series).to include('🦸‍♂️')
      end

      it 'handles XML entities correctly' do
        expect(unicode_comic.title).to include('&')
        expect(unicode_comic.title).to include('"')
      end

      it 'preserves international characters in creator names' do
        expect(unicode_comic.writer).to include('José María')
        expect(unicode_comic.penciller).to include('田中太郎')
      end
    end

    context 'with manga properties' do
      let(:manga_comic) do
        file_path = File.join(__dir__, 'fixtures', 'edge_cases', 'manga_rtl.xml')
        described_class.load(file_path)
      end

      it 'handles manga reading direction' do
        expect(manga_comic.manga).to eq('YesAndRightToLeft')
      end

      it 'identifies as black and white' do
        expect(manga_comic.black_and_white).to eq('Yes')
      end

      it 'has Japanese language ISO' do
        expect(manga_comic.language_iso).to eq('ja-JP')
      end
    end
  end

  describe 'convenience methods' do
    let(:complete_comic) { load_fixture('valid_complete.xml') }

    let(:manga_comic) { load_fixture('edge_cases/manga_rtl.xml') }

    describe '#manga?' do
      it 'returns true for manga comics' do
        expect(manga_comic.manga?).to be true
      end

      it 'returns false for non-manga comics' do
        expect(complete_comic.manga?).to be false
      end
    end

    describe '#right_to_left?' do
      it 'returns true for right-to-left manga' do
        manga_comic = load_fixture('edge_cases/manga_rtl.xml')
        expect(manga_comic.right_to_left?).to be true
      end

      it 'returns false for left-to-right comics' do
        regular_comic = load_fixture('valid_complete.xml')
        expect(regular_comic.right_to_left?).to be false
      end
    end

    describe '#black_and_white?' do
      it 'returns true for black and white comics' do
        bw_comic = load_fixture('edge_cases/manga_rtl.xml')
        expect(bw_comic.black_and_white?).to be true
      end

      it 'returns false for color comics' do
        color_comic = load_fixture('valid_complete.xml')
        expect(color_comic.black_and_white?).to be false
      end
    end

    describe '#pages?' do
      it 'returns true when pages are present' do
        expect(complete_comic.pages?).to be true
      end

      it 'returns false when no pages are present' do
        minimal_comic = load_fixture('valid_minimal.xml')
        expect(minimal_comic.pages?).to be false
      end
    end

    describe '#cover_pages' do
      it 'returns only cover pages' do
        covers = complete_comic.cover_pages
        expect(covers).to be_an(Array)
        expect(covers.length).to eq(3) # FrontCover, InnerCover, and BackCover
        expect(covers.all?(&:cover?)).to be true
      end
    end

    describe '#story_pages' do
      it 'returns only story pages' do
        stories = complete_comic.story_pages
        expect(stories).to be_an(Array)
        expect(stories.all?(&:story?)).to be true
      end
    end
  end

  describe 'validation' do
    it 'validates date components' do
      expect do
        xml_with_invalid_date = <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <ComicInfo>
            <Month>13</Month>
            <Day>32</Day>
          </ComicInfo>
        XML
        described_class.new(xml_with_invalid_date)
      end.to raise_error(ComicInfo::Errors::RangeError)
    end

    it 'validates integer type coercion' do
      expect do
        xml_with_invalid_integer = <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <ComicInfo>
            <Count>not_a_number</Count>
          </ComicInfo>
        XML
        described_class.new(xml_with_invalid_integer)
      end.to raise_error(ComicInfo::Errors::TypeCoercionError)
    end
  end

  describe 'error handling' do
    it 'provides detailed error information for enum validation' do
      xml_with_invalid_enum = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ComicInfo>
          <BlackAndWhite>Maybe</BlackAndWhite>
        </ComicInfo>
      XML
      described_class.new(xml_with_invalid_enum)
    rescue ComicInfo::Errors::InvalidEnumError => e
      expect(e.field).to eq('BlackAndWhite')
      expect(e.value).to eq('Maybe')
      expect(e.valid_values).to include('Yes', 'No', 'Unknown')
    end

    it 'provides detailed error information for range validation' do
      xml_with_invalid_rating = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ComicInfo>
          <CommunityRating>10.0</CommunityRating>
        </ComicInfo>
      XML
      described_class.new(xml_with_invalid_rating)
    rescue ComicInfo::Errors::RangeError => e
      expect(e.field).to eq('CommunityRating')
      expect(e.value).to eq(10.0)
      expect(e.min).to eq(0.0)
      expect(e.max).to eq(5.0)
    end
  end
end
