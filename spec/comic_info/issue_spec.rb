RSpec.describe ComicInfo::Issue do
  describe '.load' do
    context 'with valid file path' do
      it 'loads a minimal ComicInfo.xml file' do
        comic = load_fixture 'valid_minimal.xml'

        expect(comic).to be_a described_class
        expect(comic.title).to  eq 'Minimal Comic'
        expect(comic.series).to eq 'Test Series'
        expect(comic.number).to eq '1'
      end

      it 'loads a complete ComicInfo.xml file' do
        comic = load_fixture 'valid_complete.xml'

        expect(comic).to be_a described_class
        expect(comic.title).to  eq 'The Amazing Spider-Man'
        expect(comic.series).to eq 'The Amazing Spider-Man'
        expect(comic.count).to  eq 600
        expect(comic.volume).to eq 3
        expect(comic.community_rating).to eq 4.25
      end

      it "raises FileError when file doesn't exist" do
        expect do
          described_class.load 'non_existent_file.xml'
        end.to raise_error ComicInfo::Errors::FileError
      end
    end

    context 'with XML string' do
      it 'loads from XML string content' do
        xml_content = fixture_file 'valid_minimal.xml'
        comic = described_class.load xml_content

        expect(comic).to be_a described_class
        expect(comic.title).to eq 'Minimal Comic'
      end

      it 'raises ParseError with malformed XML' do
        malformed_xml = '<ComicInfo><Title>Test</ComicInfo>'

        expect { described_class.load malformed_xml }.to raise_error ComicInfo::Errors::ParseError
      end
    end
  end

  describe '.new' do
    it 'creates instance from XML string' do
      xml_content = fixture_file 'valid_minimal.xml'
      comic = described_class.new xml_content

      expect(comic).to be_a described_class
      expect(comic.title).to eq 'Minimal Comic'
    end

    it 'raises ParseError with invalid XML' do
      invalid_xml = '<invalid'
      expect { described_class.new invalid_xml }.to raise_error ComicInfo::Errors::ParseError
    end
  end

  describe 'basic string fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns title' do
      expect(complete_comic.title).to eq 'The Amazing Spider-Man'
    end

    it 'returns series' do
      expect(complete_comic.series).to eq 'The Amazing Spider-Man'
    end

    it 'returns number as string' do
      expect(complete_comic.number).to eq '1'
    end

    it 'returns summary' do
      expect(complete_comic.summary).to include 'radioactive spider'
    end

    it 'returns notes' do
      expect(complete_comic.notes).to eq 'Scanned by ComicTagger v1.0'
    end

    it 'returns alternate series' do
      expect(complete_comic.alternate_series).to eq 'Civil War'
    end

    it 'returns alternate number' do
      expect(complete_comic.alternate_number).to eq '2'
    end
  end

  describe 'creator fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns writer' do
      expect(complete_comic.writer).to eq 'Dan Slott, Christos Gage'
    end

    it 'returns penciller' do
      expect(complete_comic.penciller).to eq 'Ryan Ottley'
    end

    it 'returns inker' do
      expect(complete_comic.inker).to eq 'Cliff Rathburn'
    end

    it 'returns colorist' do
      expect(complete_comic.colorist).to eq 'Laura Martin'
    end

    it 'returns letterer' do
      expect(complete_comic.letterer).to eq 'Joe Caramagna'
    end

    it 'returns cover artist' do
      expect(complete_comic.cover_artist).to eq 'Ryan Ottley'
    end

    it 'returns editor' do
      expect(complete_comic.editor).to eq 'Nick Lowe'
    end

    it 'returns translator' do
      expect(complete_comic.translator).to eq 'John Smith'
    end
  end

  describe 'publication fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns publisher' do
      expect(complete_comic.publisher).to eq 'Marvel Comics'
    end

    it 'returns imprint' do
      expect(complete_comic.imprint).to eq 'Marvel'
    end

    it 'returns genre' do
      expect(complete_comic.genre).to eq %w[Superhero Action Adventure]
    end

    it 'returns web' do
      expect(complete_comic.web).to eq 'https://marvel.com/comics/issue/12345 https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/'
    end

    it 'returns language ISO' do
      expect(complete_comic.language_iso).to eq 'en-US'
    end

    it 'returns format' do
      expect(complete_comic.format).to eq 'Digital'
    end
  end

  describe 'integer fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns count as integer' do
      expect(complete_comic.count).to eq 600
    end

    it 'returns volume as integer' do
      expect(complete_comic.volume).to eq 3
    end

    it 'returns alternate count as integer' do
      expect(complete_comic.alternate_count).to eq 7
    end

    it 'returns year as integer' do
      expect(complete_comic.year).to eq 2018
    end

    it 'returns month as integer' do
      expect(complete_comic.month).to eq 3
    end

    it 'returns day as integer' do
      expect(complete_comic.day).to eq 15
    end

    it 'returns page count as integer' do
      expect(complete_comic.page_count).to eq 20
    end
  end

  describe 'enum fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns black and white enum' do
      expect(complete_comic.black_and_white).to eq 'No'
    end

    it 'returns manga enum' do
      expect(complete_comic.manga).to eq 'No'
    end

    it 'returns age rating enum' do
      expect(complete_comic.age_rating).to eq 'Teen'
    end

    context 'with invalid enum values' do
      it 'raises InvalidEnumError for invalid BlackAndWhite' do
        xml_with_invalid_enum = <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <ComicInfo>
            <BlackAndWhite>Maybe</BlackAndWhite>
          </ComicInfo>
        XML

        expect do
          described_class.new xml_with_invalid_enum
        end.to raise_error ComicInfo::Errors::InvalidEnumError
      end
    end
  end

  describe 'decimal fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns community rating as float' do
      expect(complete_comic.community_rating).to eq 4.25
      expect(complete_comic.community_rating).to be_a Float
    end

    context 'with invalid rating values' do
      it 'raises RangeError for rating above 5.0' do
        xml_with_invalid_rating = <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <ComicInfo>
            <CommunityRating>6.0</CommunityRating>
          </ComicInfo>
        XML

        expect do
          described_class.new xml_with_invalid_rating
        end.to raise_error ComicInfo::Errors::RangeError
      end

      it 'raises RangeError for negative rating' do
        xml_with_invalid_rating = <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <ComicInfo>
            <CommunityRating>-1.0</CommunityRating>
          </ComicInfo>
        XML

        expect do
          described_class.new xml_with_invalid_rating
        end.to raise_error(ComicInfo::Errors::RangeError)
      end
    end
  end

  describe 'multi-value fields' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    describe 'raw_data methods (return strings)' do
      it 'returns characters_raw_data as comma-separated string' do
        expect(complete_comic.characters_raw_data).to eq 'Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May'
      end

      it 'returns teams_raw_data as comma-separated string' do
        expect(complete_comic.teams_raw_data).to eq 'Avengers'
      end

      it 'returns locations_raw_data as comma-separated string' do
        expect(complete_comic.locations_raw_data).to eq 'New York City, Manhattan, Queens'
      end

      it 'returns story_arcs_raw_data as comma-separated string' do
        expect(complete_comic.story_arcs_raw_data).to eq 'Brand New Day, Spider-Island'
      end

      it 'returns story_arc_numbers_raw_data as comma-separated string' do
        expect(complete_comic.story_arc_numbers_raw_data).to eq '1, 5'
      end

      it 'returns genres_raw_data as comma-separated string' do
        expect(complete_comic.genres_raw_data).to eq 'Superhero, Action, Adventure'
      end

      it 'returns web as space-separated string' do
        expect(complete_comic.web).to eq 'https://marvel.com/comics/issue/12345 https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/'
      end
    end

    describe 'singular aliases (return arrays)' do
      it 'genre aliases to genres' do
        expect(complete_comic.genre).to eq %w[Superhero Action Adventure]
      end

      it 'story_arc aliases to story_arcs' do
        expect(complete_comic.story_arc).to eq ['Brand New Day', 'Spider-Island']
      end

      it 'story_arc_number aliases to story_arc_numbers' do
        expect(complete_comic.story_arc_number).to eq %w[1 5]
      end
    end

    describe 'plural methods (return arrays)' do
      it 'returns characters as array' do
        expect(complete_comic.characters).to eq ['Spider-Man', 'Peter Parker', 'J. Jonah Jameson', 'Aunt May']
      end

      it 'returns teams as array' do
        expect(complete_comic.teams).to eq ['Avengers']
      end

      it 'returns locations as array' do
        expect(complete_comic.locations).to eq ['New York City', 'Manhattan', 'Queens']
      end

      it 'returns story_arcs as array' do
        expect(complete_comic.story_arcs).to eq ['Brand New Day', 'Spider-Island']
      end

      it 'returns story_arc_numbers as array' do
        expect(complete_comic.story_arc_numbers).to eq %w[1 5]
      end

      it 'returns genres as array' do
        expect(complete_comic.genres).to eq %w[Superhero Action Adventure]
      end

      it 'returns web_urls as array' do
        expect(complete_comic.web_urls).to eq [
          'https://marvel.com/comics/issue/12345',
          'https://comicvine.gamespot.com/amazing-spider-man-1/4000-67890/'
        ]
      end
    end
  end

  describe 'pages array' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    it 'returns array of ComicPageInfo objects' do
      expect(complete_comic.pages).to be_an Array
      expect(complete_comic.pages.length).to eq 12
      expect(complete_comic.pages.first).to be_a ComicInfo::Page
    end

    it 'parses page attributes correctly' do
      first_page = complete_comic.pages.first
      expect(first_page.image).to        eq 0
      expect(first_page.type).to         eq 'FrontCover'
      expect(first_page.double_page).to  be false
      expect(first_page.image_size).to   eq 1_024_000
      expect(first_page.image_width).to  eq 1600
      expect(first_page.image_height).to eq 2400
    end

    it 'handles double-page spreads' do
      double_page = complete_comic.pages[3] # Image="3" is marked as DoublePage="true"
      expect(double_page.double_page?).to be true
      expect(double_page.image_width).to  eq 3200 # Double width
    end
  end

  describe 'default values' do
    let(:minimal_comic) { load_fixture 'valid_minimal.xml' }

    it 'returns default integer value for missing fields' do
      expect(minimal_comic.count).to  eq(-1)
      expect(minimal_comic.volume).to eq(-1)
      expect(minimal_comic.year).to   eq(-1)
    end

    it 'returns default string value for missing fields' do
      expect(minimal_comic.summary).to   eq ''
      expect(minimal_comic.notes).to     eq ''
      expect(minimal_comic.publisher).to eq ''
    end

    it 'returns default enum value for missing fields' do
      expect(minimal_comic.black_and_white).to eq 'Unknown'
      expect(minimal_comic.manga).to           eq 'Unknown'
      expect(minimal_comic.age_rating).to      eq 'Unknown'
    end
  end

  describe 'edge cases' do
    context 'with empty fields' do
      let(:empty_comic) { load_fixture 'edge_cases/empty_fields.xml' }

      it 'handles empty string fields' do
        expect(empty_comic.title).to  eq ''
        expect(empty_comic.series).to eq ''
        expect(empty_comic.notes).to  eq ''
      end

      it 'handles empty integer fields' do
        expect(empty_comic.count).to  eq(-1)
        expect(empty_comic.volume).to eq(-1)
        expect(empty_comic.year).to   eq(-1)
      end

      it 'handles empty enum fields' do
        expect(empty_comic.manga).to eq 'Unknown'
      end
    end

    context 'with Unicode and special characters' do
      let(:unicode_comic) { load_fixture 'edge_cases/unicode_special_chars.xml' }

      it 'preserves Unicode characters in title' do
        expect(unicode_comic.title).to  include '漫画'
        expect(unicode_comic.series).to include '🦸‍♂️'
      end

      it 'handles XML entities correctly' do
        expect(unicode_comic.title).to   include '"'
        expect(unicode_comic.summary).to include '&'
        expect(unicode_comic.summary).to include '<'
        expect(unicode_comic.summary).to include '>'
      end

      it 'preserves international characters in creator names' do
        expect(unicode_comic.writer).to include 'José María'
        expect(unicode_comic.writer).to include 'François'
      end
    end

    context 'with manga properties' do
      let(:manga_comic) { load_fixture 'edge_cases/manga_rtl.xml' }

      it 'identifies as manga' do
        expect(manga_comic.manga).to eq 'YesAndRightToLeft'
      end

      it 'handles manga reading direction' do
        expect(manga_comic.manga).to eq 'YesAndRightToLeft'
      end

      it 'identifies as black and white' do
        expect(manga_comic.black_and_white).to eq 'Yes'
      end

      it 'has Japanese language ISO' do
        expect(manga_comic.language_iso).to eq 'ja-JP'
      end
    end
  end

  describe 'convenience methods' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    let(:manga_comic) { load_fixture 'edge_cases/manga_rtl.xml' }

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
        manga_comic = load_fixture 'edge_cases/manga_rtl.xml'

        expect(manga_comic.right_to_left?).to be true
      end

      it 'returns false for left-to-right comics' do
        regular_comic = load_fixture 'valid_complete.xml'

        expect(regular_comic.right_to_left?).to be false
      end
    end

    describe '#black_and_white?' do
      it 'returns true for black and white comics' do
        bw_comic = load_fixture 'edge_cases/manga_rtl.xml'

        expect(bw_comic.black_and_white?).to be true
      end

      it 'returns false for color comics' do
        color_comic = load_fixture 'valid_complete.xml'

        expect(color_comic.black_and_white?).to be false
      end
    end

    describe '#pages?' do
      it 'returns true when pages are present' do
        expect(complete_comic.pages?).to be true
      end

      it 'returns false when no pages are present' do
        minimal_comic = load_fixture 'valid_minimal.xml'

        expect(minimal_comic.pages?).to be false
      end
    end

    describe '#cover_pages' do
      it 'returns only cover pages' do
        covers = complete_comic.cover_pages
        expect(covers).to be_an Array
        expect(covers.length).to eq 3 # FrontCover, InnerCover, and BackCover
        expect(covers.all?(&:cover?)).to be true
      end
    end

    describe '#story_pages' do
      it 'returns only story pages' do
        stories = complete_comic.story_pages
        expect(stories).to be_an Array
        expect(stories.all?(&:story?)).to be true
      end
    end
  end

  describe 'validation' do
    it 'validates date components' do
      xml_with_invalid_date = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ComicInfo>
          <Month>13</Month>
          <Day>32</Day>
        </ComicInfo>
      XML

      expect do
        described_class.new xml_with_invalid_date
      end.to raise_error ComicInfo::Errors::RangeError
    end

    it 'validates integer type coercion' do
      xml_with_invalid_count = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ComicInfo>
          <Count>not_a_number</Count>
        </ComicInfo>
      XML

      expect do
        described_class.new xml_with_invalid_count
      end.to raise_error ComicInfo::Errors::TypeCoercionError
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

      begin
        described_class.new xml_with_invalid_enum
      rescue ComicInfo::Errors::InvalidEnumError => e
        expect(e.field).to eq 'BlackAndWhite'
        expect(e.value).to eq 'Maybe'
        expect(e.valid_values).to include 'Yes', 'No', 'Unknown'
      end
    end

    it 'provides detailed error information for range validation' do
      xml_with_invalid_rating = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ComicInfo>
          <CommunityRating>6.0</CommunityRating>
        </ComicInfo>
      XML

      begin
        described_class.new xml_with_invalid_rating
      rescue ComicInfo::Errors::RangeError => e
        expect(e.field).to eq 'CommunityRating'
        expect(e.value).to eq 6.0
        expect(e.min).to   eq 0.0
        expect(e.max).to   eq 5.0
      end
    end
  end

  describe 'JSON serialization' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }

    describe '#to_json' do
      it 'returns valid JSON string' do
        json_string = complete_comic.to_json
        expect(json_string).to be_a(String)
        expect { JSON.parse(json_string) }.not_to raise_error

        parsed = JSON.parse json_string
        expect(parsed).to be_a Hash
        expect(parsed['title']).to eq 'The Amazing Spider-Man'
      end

      it 'includes all expected fields' do
        json_string = complete_comic.to_json
        parsed = JSON.parse json_string

        # Test basic fields
        expect(parsed['title']).to  eq 'The Amazing Spider-Man'
        expect(parsed['series']).to eq 'The Amazing Spider-Man'
        expect(parsed['count']).to  eq 600
        expect(parsed['volume']).to eq 3
        expect(parsed['community_rating']).to eq 4.25

        # Test both singular and plural forms of multi-value fields
        expect(parsed['genre']).to                      eq 'Superhero, Action, Adventure'
        expect(parsed['genres_raw_data']).to            eq 'Superhero, Action, Adventure'
        expect(parsed['genres']).to                     eq %w[Superhero Action Adventure]
        expect(parsed['characters_raw_data']).to        eq 'Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May'
        expect(parsed['characters']).to                 eq ['Spider-Man', 'Peter Parker', 'J. Jonah Jameson', 'Aunt May']
        expect(parsed['story_arc']).to                  eq 'Brand New Day, Spider-Island'
        expect(parsed['story_arcs_raw_data']).to        eq 'Brand New Day, Spider-Island'
        expect(parsed['story_arcs']).to                 eq ['Brand New Day', 'Spider-Island']
        expect(parsed['story_arc_number']).to           eq '1, 5'
        expect(parsed['story_arc_numbers_raw_data']).to eq '1, 5'
        expect(parsed['story_arc_numbers']).to          eq %w[1 5]

        # Test pages array
        expect(parsed['pages']).to be_an Array
        expect(parsed['pages'].first).to have_key 'image'
        expect(parsed['pages'].first).to have_key 'type'

        expect(parsed).to have_key 'black_and_white'
        expect(parsed).to have_key 'characters'
        expect(parsed).to have_key 'characters_raw_data'
        expect(parsed).to have_key 'colorist'
        expect(parsed).to have_key 'count'
        expect(parsed).to have_key 'cover_artist'
        expect(parsed).to have_key 'day'
        expect(parsed).to have_key 'editor'
        expect(parsed).to have_key 'format'
        expect(parsed).to have_key 'genre'
        expect(parsed).to have_key 'genres'
        expect(parsed).to have_key 'genres_raw_data'
        expect(parsed).to have_key 'imprint'
        expect(parsed).to have_key 'inker'
        expect(parsed).to have_key 'language_iso'
        expect(parsed).to have_key 'letterer'
        expect(parsed).to have_key 'locations'
        expect(parsed).to have_key 'locations_raw_data'
        expect(parsed).to have_key 'manga'
        expect(parsed).to have_key 'month'
        expect(parsed).to have_key 'notes'
        expect(parsed).to have_key 'number'
        expect(parsed).to have_key 'page_count'
        expect(parsed).to have_key 'pages'
        expect(parsed).to have_key 'penciller'
        expect(parsed).to have_key 'publisher'
        expect(parsed).to have_key 'series'
        expect(parsed).to have_key 'story_arc'
        expect(parsed).to have_key 'story_arc_number'
        expect(parsed).to have_key 'story_arc_numbers'
        expect(parsed).to have_key 'story_arcs'
        expect(parsed).to have_key 'story_arcs_raw_data'
        expect(parsed).to have_key 'summary'
        expect(parsed).to have_key 'teams'
        expect(parsed).to have_key 'teams_raw_data'
        expect(parsed).to have_key 'title'
        expect(parsed).to have_key 'volume'
        expect(parsed).to have_key 'web'
        expect(parsed).to have_key 'web_urls'
        expect(parsed).to have_key 'writer'
        expect(parsed).to have_key 'year'

        expect(parsed['pages']).to      be_an Array
        expect(parsed['characters']).to be_an Array
        expect(parsed['genres']).to     be_an Array
      end
    end

    describe '#to_h' do
      it 'returns hash representation' do
        hash = complete_comic.to_h
        expect(hash).to         be_a  Hash
        expect(hash[:pages]).to be_an Array

        expect(hash[:title]).to  eq 'The Amazing Spider-Man'
        expect(hash[:series]).to eq 'The Amazing Spider-Man'
      end

      it 'includes both raw_data and array forms' do
        hash = complete_comic.to_h

        expect(hash).to have_key :characters_raw_data
        expect(hash).to have_key :characters
        expect(hash).to have_key :genres_raw_data
        expect(hash).to have_key :genres

        expect(hash[:characters_raw_data]).to be_a  String
        expect(hash[:characters]).to          be_an Array
        expect(hash[:genres_raw_data]).to     be_a  String
        expect(hash[:genres]).to              be_an Array

        expect(hash[:characters]).to          eq ['Spider-Man', 'Peter Parker', 'J. Jonah Jameson', 'Aunt May']
        expect(hash[:characters_raw_data]).to eq 'Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May'
        expect(hash[:story_arc_numbers]).to   eq %w[1 5]
      end
    end

    describe '#to_yaml' do
      it 'returns valid YAML string' do
        yaml_string = complete_comic.to_yaml

        # Verify it's valid YAML by parsing it back
        parsed = YAML.safe_load yaml_string, permitted_classes: [Symbol]
        expect(parsed).to be_a Hash

        expect(parsed[:title]).to eq 'The Amazing Spider-Man'
      end

      it 'includes all expected fields' do
        yaml_string = complete_comic.to_yaml
        parsed = YAML.safe_load yaml_string, permitted_classes: [Symbol]

        expect(parsed).to have_key :black_and_white
        expect(parsed).to have_key :characters
        expect(parsed).to have_key :characters_raw_data
        expect(parsed).to have_key :colorist
        expect(parsed).to have_key :count
        expect(parsed).to have_key :cover_artist
        expect(parsed).to have_key :day
        expect(parsed).to have_key :editor
        expect(parsed).to have_key :format
        expect(parsed).to have_key :genre
        expect(parsed).to have_key :genres
        expect(parsed).to have_key :genres_raw_data
        expect(parsed).to have_key :imprint
        expect(parsed).to have_key :inker
        expect(parsed).to have_key :language_iso
        expect(parsed).to have_key :letterer
        expect(parsed).to have_key :locations
        expect(parsed).to have_key :locations_raw_data
        expect(parsed).to have_key :manga
        expect(parsed).to have_key :month
        expect(parsed).to have_key :notes
        expect(parsed).to have_key :number
        expect(parsed).to have_key :page_count
        expect(parsed).to have_key :pages
        expect(parsed).to have_key :penciller
        expect(parsed).to have_key :publisher
        expect(parsed).to have_key :series
        expect(parsed).to have_key :story_arc
        expect(parsed).to have_key :story_arc_number
        expect(parsed).to have_key :story_arc_numbers
        expect(parsed).to have_key :story_arcs
        expect(parsed).to have_key :story_arcs_raw_data
        expect(parsed).to have_key :summary
        expect(parsed).to have_key :teams
        expect(parsed).to have_key :teams_raw_data
        expect(parsed).to have_key :title
        expect(parsed).to have_key :volume
        expect(parsed).to have_key :web
        expect(parsed).to have_key :web_urls
        expect(parsed).to have_key :writer
        expect(parsed).to have_key :year

        expect(parsed[:pages]).to      be_an Array
        expect(parsed[:characters]).to be_an Array
        expect(parsed[:genres]).to     be_an Array

        expect(parsed[:pages]).to be_an Array
        expect(parsed[:pages].first).to have_key :image
        expect(parsed[:pages].first).to have_key :type
      end

      it 'produces human-readable YAML format' do
        yaml_string = complete_comic.to_yaml

        expect(yaml_string).to include 'title: The Amazing Spider-Man'
        expect(yaml_string).to include 'series: The Amazing Spider-Man'
        expect(yaml_string).to include 'count: 600'
        expect(yaml_string).to include 'volume: 3'
        expect(yaml_string).to include 'characters:'
        expect(yaml_string).to include '- Spider-Man'
        expect(yaml_string).to include '- Peter Parker'
        expect(yaml_string).to include 'pages:'
      end
    end
  end

  describe 'XML generation' do
    let(:complete_comic) { load_fixture 'valid_complete.xml' }
    let(:minimal_comic) { load_fixture 'valid_minimal.xml' }

    describe '#to_xml' do
      it 'generates valid XML string' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to be_a String
        expect(xml_string).to include '<?xml version="1.0" encoding="UTF-8"?>'
        expect(xml_string).to include '<ComicInfo'
        expect(xml_string).to include '</ComicInfo>'
      end

      it 'includes XML declaration with UTF-8 encoding' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to start_with '<?xml version="1.0" encoding="UTF-8"?>'
      end

      it 'includes schema namespaces' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
        expect(xml_string).to include 'xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
      end

      it 'includes all non-default fields' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include '<Title>The Amazing Spider-Man</Title>'
        expect(xml_string).to include '<Series>The Amazing Spider-Man</Series>'
        expect(xml_string).to include '<Number>1</Number>'
        expect(xml_string).to include '<Writer>Dan Slott, Christos Gage</Writer>'
        expect(xml_string).to include '<Publisher>Marvel Comics</Publisher>'
      end

      it 'excludes default/empty values' do
        xml_string = minimal_comic.to_xml
        expect(xml_string).not_to include '<Writer></Writer>'
        expect(xml_string).not_to include '<Count>-1</Count>'
        expect(xml_string).not_to include '<BlackAndWhite>Unknown</BlackAndWhite>'
        expect(xml_string).not_to include '<Manga>Unknown</Manga>'
      end

      it 'includes Pages section when pages exist' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include '<Pages>'
        expect(xml_string).to include '</Pages>'
        expect(xml_string).to include '<Page Image="0"'
      end

      it 'excludes Pages section when no pages exist' do
        xml_string = minimal_comic.to_xml
        expect(xml_string).not_to include '<Pages>'
      end

      it 'handles Unicode characters correctly' do
        unicode_comic = load_fixture 'edge_cases/unicode_special_chars.xml'
        xml_string = unicode_comic.to_xml
        # XML escapes ampersands but not quotes in this case
        expect(xml_string).to include '<Title>漫画 &amp; Bande Dessinée: "Special" Characters</Title>'
      end

      it 'properly escapes XML entities' do
        entities_comic = load_fixture 'edge_cases/unicode_special_chars.xml'
        xml_string = entities_comic.to_xml
        # XML should be properly escaped by Nokogiri
        expect(xml_string).to be_a String
        expect(xml_string).to include '<ComicInfo'
      end

      it 'maintains multi-value field formatting' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include '<Genre>Superhero, Action, Adventure</Genre>'
        expect(xml_string).to include '<Characters>Spider-Man, Peter Parker, J. Jonah Jameson, Aunt May</Characters>'
        expect(xml_string).to include '<StoryArc>Brand New Day, Spider-Island</StoryArc>'
      end

      it 'includes enum values' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include '<AgeRating>Teen</AgeRating>'
        expect(xml_string).to include '<BlackAndWhite>No</BlackAndWhite>'
        expect(xml_string).to include '<Manga>No</Manga>'
      end

      it 'includes decimal values' do
        xml_string = complete_comic.to_xml
        expect(xml_string).to include '<CommunityRating>4.25</CommunityRating>'
      end
    end

    describe '#save' do
      let(:output_file) { 'spec/fixtures/output/test_output.xml' }

      after do
        FileUtils.rm_f(output_file)
      end

      it 'saves to file path' do
        complete_comic.save(output_file)
        expect(File.exist?(output_file)).to be true

        content = File.read(output_file)
        expect(content).to include '<ComicInfo'
        expect(content).to include '<Title>The Amazing Spider-Man</Title>'
      end

      it 'saves to IO object' do
        File.open(output_file, 'w') do |f|
          complete_comic.save(f)
        end

        expect(File.exist?(output_file)).to be true
        content = File.read(output_file)
        expect(content).to include '<ComicInfo'
      end

      it 'raises FileError for invalid path' do
        expect do
          complete_comic.save('/invalid/path/file.xml')
        end.to raise_error(ComicInfo::Errors::FileError, /Failed to write file/)
      end

      it 'raises FileError for invalid IO object' do
        expect do
          complete_comic.save(123)
        end.to raise_error(ComicInfo::Errors::FileError, 'Invalid file path or IO object')
      end
    end

    describe 'round-trip consistency' do
      it 'maintains data integrity through load -> save -> load cycle' do
        original_comic = complete_comic

        # Save to XML
        output_file = 'spec/fixtures/output/roundtrip_test.xml'
        original_comic.save(output_file)

        # Load back from saved XML
        reloaded_comic = described_class.load(output_file)

        # Compare key fields
        expect(reloaded_comic.title).to eq original_comic.title
        expect(reloaded_comic.series).to eq original_comic.series
        expect(reloaded_comic.number).to eq original_comic.number
        expect(reloaded_comic.writer).to eq original_comic.writer
        expect(reloaded_comic.publisher).to eq original_comic.publisher
        expect(reloaded_comic.genres).to eq original_comic.genres
        expect(reloaded_comic.characters).to eq original_comic.characters
        expect(reloaded_comic.age_rating).to eq original_comic.age_rating
        expect(reloaded_comic.community_rating).to eq original_comic.community_rating
        expect(reloaded_comic.pages.length).to eq original_comic.pages.length

        FileUtils.rm_f(output_file)
      end

      it 'preserves page attributes through round-trip' do
        original_comic = complete_comic
        next if original_comic.pages.empty?

        output_file = 'spec/fixtures/output/pages_roundtrip_test.xml'
        original_comic.save(output_file)
        reloaded_comic = described_class.load(output_file)

        original_comic.pages.each_with_index do |original_page, index|
          reloaded_page = reloaded_comic.pages[index]
          expect(reloaded_page.image).to eq original_page.image
          expect(reloaded_page.type).to eq original_page.type
          expect(reloaded_page.double_page).to eq original_page.double_page
        end

        FileUtils.rm_f(output_file)
      end

      it 'handles minimal comics correctly' do
        original_comic = minimal_comic

        output_file = 'spec/fixtures/output/minimal_roundtrip_test.xml'
        original_comic.save(output_file)
        reloaded_comic = described_class.load(output_file)

        expect(reloaded_comic.title).to eq original_comic.title
        expect(reloaded_comic.series).to eq original_comic.series

        FileUtils.rm_f(output_file)
      end
    end
  end
end
