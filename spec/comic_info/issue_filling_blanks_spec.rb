RSpec.describe ComicInfo::Issue do
  describe '#with_blanks_filled_from' do
    let(:found) { load_fixture 'valid_complete.xml' }

    it 'fills every blank field from the found issue' do
      issue  = load_fixture 'edge_cases/empty_fields.xml'
      filled = issue.with_blanks_filled_from found

      expect(filled.to_h.except(:pages)).to eq found.to_h.except(:pages)
    end

    it 'keeps the fields already set' do
      issue  = load_fixture 'filling_blanks/partly_set.xml'
      filled = issue.with_blanks_filled_from found

      expect(filled.series).to eq 'Saga'
      expect(filled.number).to eq '7'
      expect(filled.writer).to eq 'Brian K. Vaughan'
      expect(filled.year).to eq 2012
      expect(filled.age_rating).to eq 'Mature 17+'
      expect(filled.community_rating).to eq 4.5
      expect(filled.characters).to eq ['Alana']
      expect(filled.title).to eq found.title
      expect(filled.publisher).to eq found.publisher
      expect(filled.month).to eq found.month
    end

    it 'counts whitespace as blank' do
      issue  = load_fixture 'filling_blanks/whitespace.xml'
      filled = issue.with_blanks_filled_from load_fixture('filename/saga.xml')

      expect(filled.series).to eq 'Saga'
      expect(filled.title).to eq 'Chapter One'
    end

    it 'counts Unknown enums as blank' do
      issue  = load_fixture 'filling_blanks/unknown_enums.xml'
      filled = issue.with_blanks_filled_from load_fixture('edge_cases/manga_rtl.xml')

      expect(filled.age_rating).to eq 'Teen'
      expect(filled.black_and_white).to eq 'Yes'
      expect(filled.manga).to eq 'YesAndRightToLeft'
    end

    it 'keeps the pages and the page count' do
      issue  = load_fixture 'pages/three_pages.xml'
      filled = issue.with_blanks_filled_from found

      expect(filled.pages.map(&:to_h)).to eq issue.pages.map(&:to_h)
      expect(filled.page_count).to eq 3
    end

    it 'takes the page count only when the issue has none' do
      issue  = load_fixture 'pages/one_entry.xml'
      filled = issue.with_blanks_filled_from found

      expect(filled.page_count).to eq 20
      expect(filled.pages.map(&:to_h)).to eq issue.pages.map(&:to_h)
    end

    it 'leaves the issue it was called on as it was' do
      issue = load_fixture 'filename/series_only.xml'
      issue.with_blanks_filled_from found

      expect(issue.title).to be_empty
      expect(issue.to_xml).to eq load_fixture('filename/series_only.xml').to_xml
    end
  end
end
