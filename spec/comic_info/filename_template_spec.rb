RSpec.describe ComicInfo::FilenameTemplate do
  # The template is literal text: #{number} here is a "#" then a {number} token, not interpolation.
  let(:template) { '{series} #{number} ({year})' } # rubocop:disable Lint/InterpolationCheck

  describe 'Issue#filename' do
    it 'fills in every token' do
      issue = load_fixture 'filename/saga.xml'

      expect(issue.filename(template:)).to eq 'Saga #1 (2012)'
      expect(issue.filename(template: '{publisher} - {series} v{volume} - {title}')).to eq 'Image - Saga v2 - Chapter One'
    end

    it 'names the complete fixture issue' do
      issue = load_fixture 'valid_complete.xml'

      expect(issue.filename(template:)).to eq 'The Amazing Spider-Man #1 (2018)'
    end

    it 'leaves no empty decoration around missing values' do
      expect(load_fixture('filename/series_only.xml').filename(template:)).to   eq 'Saga'
      expect(load_fixture('filename/series_number.xml').filename(template:)).to eq 'Saga #1'
      expect(load_fixture('filename/series_year.xml').filename(template:)).to   eq 'Saga (2012)'
      expect(load_fixture('filename/series_only.xml').filename(template: '{series} [{year}]')).to eq 'Saga'
    end

    it 'gives an empty name for an issue with no values' do
      expect(load_fixture('filename/no_details.xml').filename(template:)).to eq ''
    end

    it 'replaces characters that cannot be in a file name' do
      issue = load_fixture 'filename/unsafe_characters.xml'

      name = issue.filename template: '{series} #{number}' # rubocop:disable Lint/InterpolationCheck

      expect(name).to eq 'Batman- Year One #1-2'
    end

    it 'collapses and trims whitespace' do
      issue = load_fixture 'filename/padded_spaces.xml'

      expect(issue.filename(template: ' {series}   {title} ')).to eq 'Saga One'
    end

    it 'leaves unknown tokens and plain text alone' do
      issue = load_fixture 'filename/series_only.xml'

      expect(issue.filename(template: '{series} {colour} scan')).to eq 'Saga {colour} scan'
    end

    it 'pads the number with zeros to a width' do
      issue = load_fixture 'filename/saga.xml'

      expect(issue.filename(template: '{series} #{number:3} ({year})')).to eq 'Saga #001 (2012)'
      expect(issue.filename(template: '{number:2}')).to eq '01'
      expect(issue.filename(template: '{number:1}')).to eq '1'
      expect(issue.filename(template: '{number} {number:4}')).to eq '1 0001'
    end

    it 'pads only the whole number the value starts with' do
      padded = '{number:3}'

      expect(load_fixture('filename/number_decimal.xml').filename(template: padded)).to    eq '001.5'
      expect(load_fixture('filename/number_suffix.xml').filename(template: padded)).to     eq '012AU'
      expect(load_fixture('filename/number_thousand.xml').filename(template: padded)).to   eq '1000'
      expect(load_fixture('filename/number_word.xml').filename(template: padded)).to       eq 'Annual'
      expect(load_fixture('filename/unsafe_characters.xml').filename(template: padded)).to eq '001-2'
    end

    it 'leaves a width that is not 1 to 99 as written' do
      issue = load_fixture 'filename/saga.xml'

      expect(issue.filename(template: '{number:0}')).to   eq '{number:0}'
      expect(issue.filename(template: '{number:100}')).to eq '{number:100}'
      expect(issue.filename(template: '{number:x}')).to   eq '{number:x}'
    end

    it 'pads no other token' do
      issue = load_fixture 'filename/saga.xml'

      expect(issue.filename(template: '{year:6}')).to eq '{year:6}'
    end
  end

  describe 'Issue#page_filename' do
    let(:issue) { load_fixture 'filename/number_seven.xml' }

    it 'fills in the page number' do
      expect(issue.page_filename(template: 'page_{page:3}', page: 1, of: 22)).to  eq 'page_001'
      expect(issue.page_filename(template: 'page_{page:3}', page: 22, of: 22)).to eq 'page_022'
      expect(issue.page_filename(template: '{page:4}', page: 5, of: 22)).to       eq '0005'
    end

    it 'fills in issue tokens too' do
      name = issue.page_filename template: '{series}_{number:3}_{page:4}', page: 12, of: 22

      expect(name).to eq 'Saga_007_0012'
    end

    it 'names a page of the complete fixture issue' do
      issue = load_fixture 'valid_complete.xml'
      name  = issue.page_filename template: '{series} #{number:3} p{page:3}', page: 2, of: 20

      expect(name).to eq 'The Amazing Spider-Man #001 p002'
    end

    it 'makes the page number at least as wide as the page count' do
      expect(issue.page_filename(template: 'page_{page}', page: 2, of: 9)).to       eq 'page_2'
      expect(issue.page_filename(template: 'page_{page}', page: 2, of: 10)).to      eq 'page_02'
      expect(issue.page_filename(template: 'page_{page:2}', page: 2, of: 150)).to   eq 'page_002'
      expect(issue.page_filename(template: 'page_{page:1}', page: 150, of: 150)).to eq 'page_150'
    end

    it 'appends a page number to a template without one' do
      expect(issue.page_filename(template: '{series}', page: 3, of: 22)).to eq 'Saga_03'
      expect(issue.page_filename(template: 'scan', page: 3, of: 22)).to     eq 'scan_03'
      expect(issue.page_filename(template: '{page:0}', page: 3, of: 22)).to eq '{page-0}_03'
    end

    it 'uses the page number alone when the name would be empty' do
      expect(issue.page_filename(template: '', page: 3, of: 22)).to eq '03'

      no_details = load_fixture 'filename/no_details.xml'
      expect(no_details.page_filename(template: '{series}', page: 3, of: 22)).to eq '03'
    end

    it 'replaces characters that cannot be in a file name' do
      issue = load_fixture 'filename/unsafe_characters.xml'

      expect(issue.page_filename(template: '{series}/{page:3}', page: 1, of: 9)).to eq 'Batman- Year One-001'
    end
  end

  describe 'tokens' do
    it 'lists the tokens a file name template can use' do
      expect(described_class::TOKENS).to eq %w[number publisher series title volume year]
    end

    it 'adds page to them for a page file name template' do
      expect(described_class::PAGE_TOKENS).to eq [*described_class::TOKENS, 'page']
    end
  end
end
