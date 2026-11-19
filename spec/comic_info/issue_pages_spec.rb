RSpec.describe ComicInfo::Issue do
  describe '#rearranging_pages' do
    let(:issue) { load_fixture 'pages/three_pages.xml' }

    it 'changes nothing for the same order' do
      result = issue.rearranging_pages [0, 1, 2]

      expect(result.pages).to eq issue.pages
      expect(result.page_count).to eq 3
    end

    it 'keeps the details of reordered pages under their new indexes' do
      result = issue.rearranging_pages [2, 0, 1]

      expect(result.pages.map(&:image)).to eq [0, 1, 2]
      expect(result.pages.map(&:type)).to eq %w[BackCover FrontCover Story]
      expect(result.pages[1].image_size).to eq 100
      expect(result.pages[2].bookmark).to eq 'Chapter 1'
      expect(result.page_count).to eq 3
    end

    it 'drops deleted pages and renumbers the rest' do
      result = issue.rearranging_pages [0, 2]

      expect(result.pages.map(&:image)).to eq [0, 1]
      expect(result.pages.map(&:type)).to eq %w[FrontCover BackCover]
      expect(result.page_count).to eq 2
    end

    it 'gives added pages a default entry' do
      result = issue.rearranging_pages [0, nil, 1, 2]

      expect(result.pages.map(&:image)).to eq [0, 1, 2, 3]
      expect(result.pages.map(&:type)).to eq %w[FrontCover Story Story BackCover]
      expect(result.pages[1]).to eq ComicInfo::Page.new(image: 1)
      expect(result.page_count).to eq 4
    end

    it 'leaves pages without an entry without one' do
      one_entry = load_fixture 'pages/one_entry.xml'
      result    = one_entry.rearranging_pages [1, 0, 2]

      expect(result.pages).to eq [ComicInfo::Page.new(image: 1, type: 'FrontCover')]
    end

    it 'adds no entries to an issue that has none' do
      no_entries = load_fixture 'pages/no_entries.xml'
      result     = no_entries.rearranging_pages [1, nil, 0]

      expect(result.pages).to be_empty
      expect(result.page_count).to eq ComicInfo::Enums::DEFAULT_PAGE_COUNT
    end

    it 'updates the page count when it was set' do
      count_only = load_fixture 'pages/count_only.xml'

      expect(count_only.rearranging_pages([0, 1]).page_count).to eq 2
    end

    it 'carries every other field over' do
      complete = load_fixture 'valid_complete.xml'
      result   = complete.rearranging_pages (0...12).to_a

      expect(result.to_h).to eq complete.to_h.merge(page_count: 12)
    end

    it 'leaves the issue it was called on as it was' do
      issue.rearranging_pages [2, 0]

      expect(issue.pages.map(&:type)).to eq %w[FrontCover Story BackCover]
      expect(issue.page_count).to eq 3
    end

    it 'writes the rearranged pages to XML' do
      result   = issue.rearranging_pages [2, 0]
      reloaded = ComicInfo.load result.to_xml

      expect(reloaded.pages.map(&:type)).to eq %w[BackCover FrontCover]
      expect(reloaded.page_count).to eq 2
      expect(reloaded.title).to eq 'Saga'
    end
  end

  describe '#page_type' do
    let(:issue) { load_fixture 'pages/four_pages_with_a_gap.xml' }

    it "is the entry's first type" do
      expect(issue.page_type(at: 0)).to eq 'FrontCover'
      expect(issue.page_type(at: 1)).to eq 'Story'
      expect(issue.page_type(at: 3)).to eq 'BackCover'
    end

    it 'is Story for a page without an entry' do
      expect(issue.page_type(at: 2)).to eq 'Story'
      expect(load_fixture('pages/no_entries.xml').page_type(at: 0)).to eq 'Story'
    end
  end

  describe '#setting_page_type' do
    let(:issue) { load_fixture 'pages/four_pages_with_a_gap.xml' }

    it "changes only that entry's type" do
      result = issue.setting_page_type 'Advertisement', at: 0

      expect(result.page_type(at: 0)).to eq 'Advertisement'
      expect(result.pages[0].image_size).to eq 100
      expect(result.pages.drop(1)).to eq issue.pages.drop(1)
      expect(result.title).to eq 'Saga'
      expect(result.page_count).to eq 4
    end

    it 'replaces every type the page had' do
      result = issue.setting_page_type 'Letters', at: 1

      expect(result.pages[1].types).to eq ['Letters']
      expect(result.pages[1]).to be_double_page
      expect(result.pages[1].bookmark).to eq 'Chapter 1'
    end

    it 'adds an entry, in image order, for a page without one' do
      result = issue.setting_page_type 'Editorial', at: 2

      expect(result.pages.map(&:image)).to eq [0, 1, 2, 3]
      expect(result.pages[2]).to eq ComicInfo::Page.new(image: 2, type: 'Editorial')
    end

    it 'adds nothing when setting Story on a page without an entry' do
      expect(issue.setting_page_type('Story', at: 2).pages).to eq issue.pages
      expect(load_fixture('pages/no_entries.xml').setting_page_type('Story', at: 0).pages).to be_empty
    end

    it 'keeps the entry when setting Story on a page that has one' do
      result = issue.setting_page_type 'Story', at: 0

      expect(result.pages[0]).to eq ComicInfo::Page.new(image: 0, type: 'Story', image_size: 100)
    end

    it 'changes nothing when the page already has the type' do
      expect(issue.setting_page_type('FrontCover', at: 0).pages).to eq issue.pages
    end

    it 'refuses a type the schema does not have' do
      expect { issue.setting_page_type 'Centerfold', at: 0 }.to raise_error ComicInfo::Errors::InvalidEnumError
    end

    it 'leaves the issue it was called on as it was' do
      issue.setting_page_type 'Advertisement', at: 0

      expect(issue.page_type(at: 0)).to eq 'FrontCover'
    end

    it 'writes the type to XML' do
      result   = issue.setting_page_type 'Editorial', at: 2
      reloaded = ComicInfo.load result.to_xml

      expect(reloaded.page_type(at: 2)).to eq 'Editorial'
      expect(reloaded.page_type(at: 0)).to eq 'FrontCover'
    end
  end
end
