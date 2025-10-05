RSpec.describe ComicInfo::Page do
  describe '#initialize' do
    it 'creates a page with required Image attribute' do
      page = described_class.new 'Image' => '0', 'Type' => 'Story'

      expect(page.image).to be_zero
      expect(page.type).to eq 'Story'
    end

    it 'raises error when Image attribute is missing' do
      expect do
        described_class.new 'Type' => 'Story'
      end.to raise_error ComicInfo::Errors::SchemaError, 'Image attribute is required for Page'
    end

    it 'raises error when Image attribute is invalid' do
      expect do
        described_class.new 'Image' => 'invalid', 'Type' => 'Story'
      end.to raise_error ComicInfo::Errors::TypeCoercionError
    end

    it 'sets default values for optional attributes' do
      page = described_class.new 'Image' => '5'

      expect(page.type).to eq 'Story'
      expect(page.double_page).to be false
      expect(page.image_size).to eq 0
      expect(page.key).to eq ''
      expect(page.bookmark).to eq ''
      expect(page.image_width).to eq(-1)
      expect(page.image_height).to eq(-1)
    end

    it 'accepts symbol keys for attributes' do
      page = described_class.new image: '3', type: 'FrontCover', double_page: 'true'

      expect(page.image).to eq 3
      expect(page.type).to eq 'FrontCover'
      expect(page.double_page).to be true
    end

    it 'handles boolean conversion for DoublePage' do
      true_page  = described_class.new 'Image' => '1', 'DoublePage' => 'true'
      false_page = described_class.new 'Image' => '2', 'DoublePage' => 'false'
      one_page   = described_class.new 'Image' => '3', 'DoublePage' => '1'
      zero_page  = described_class.new 'Image' => '4', 'DoublePage' => '0'

      expect(true_page.double_page).to be true
      expect(false_page.double_page).to be false
      expect(one_page.double_page).to be true
      expect(zero_page.double_page).to be false
    end

    it 'raises error for invalid boolean values' do
      expect do
        described_class.new 'Image' => '1', 'DoublePage' => 'maybe'
      end.to raise_error ComicInfo::Errors::TypeCoercionError
    end
  end

  describe 'page type predicates' do
    describe '#cover?' do
      it 'returns true for cover page types' do
        front_cover = described_class.new 'Image' => '0', 'Type' => 'FrontCover'
        back_cover  = described_class.new 'Image' => '1', 'Type' => 'BackCover'
        inner_cover = described_class.new 'Image' => '2', 'Type' => 'InnerCover'

        expect(front_cover.cover?).to be true
        expect(back_cover.cover?).to be true
        expect(inner_cover.cover?).to be true
      end

      it 'returns false for non-cover page types' do
        story_page   = described_class.new 'Image' => '3', 'Type' => 'Story'
        ad_page      = described_class.new 'Image' => '4', 'Type' => 'Advertisement'
        deleted_page = described_class.new 'Image' => '5', 'Type' => 'Deleted'

        expect(story_page.cover?).to be false
        expect(ad_page.cover?).to be false
        expect(deleted_page.cover?).to be false
      end
    end

    describe '#story?' do
      it 'returns true for story pages' do
        story_page = described_class.new 'Image' => '3', 'Type' => 'Story'
        expect(story_page.story?).to be true
      end

      it 'returns false for non-story pages' do
        front_cover  = described_class.new 'Image' => '0', 'Type' => 'FrontCover'
        ad_page      = described_class.new 'Image' => '4', 'Type' => 'Advertisement'
        deleted_page = described_class.new 'Image' => '5', 'Type' => 'Deleted'

        expect(front_cover.story?).to be false
        expect(ad_page.story?).to be false
        expect(deleted_page.story?).to be false
      end
    end

    describe '#deleted?' do
      it 'returns true for deleted pages' do
        deleted_page = described_class.new 'Image' => '5', 'Type' => 'Deleted'

        expect(deleted_page.deleted?).to be true
      end

      it 'returns false for non-deleted pages' do
        front_cover = described_class.new 'Image' => '0', 'Type' => 'FrontCover'
        story_page  = described_class.new 'Image' => '3', 'Type' => 'Story'
        ad_page     = described_class.new 'Image' => '4', 'Type' => 'Advertisement'

        expect(front_cover.deleted?).to be false
        expect(story_page.deleted?).to be false
        expect(ad_page.deleted?).to be false
      end
    end
  end

  describe '#double_page?' do
    it 'returns true when double_page is true' do
      page = described_class.new 'Image' => '1', 'DoublePage' => 'true'

      expect(page.double_page?).to be true
    end

    it 'returns false when double_page is false' do
      page = described_class.new 'Image' => '1', 'DoublePage' => 'false'

      expect(page.double_page?).to be false
    end
  end

  describe '#types' do
    it 'returns single type as array' do
      page = described_class.new 'Image' => '1', 'Type' => 'Story'

      expect(page.types).to eq ['Story']
    end

    it 'handles space-separated multiple types' do
      page = described_class.new 'Image' => '1', 'Type' => 'Story Advertisement'

      expect(page.types).to eq %w[Story Advertisement]
    end

    it 'handles tabs and multiple spaces' do
      page = described_class.new 'Image' => '1', 'Type' => 'Story  Advertisement	Editorial'

      expect(page.types).to eq %w[Story Advertisement Editorial]
    end
  end

  describe '#include_type?' do
    let(:page) { described_class.new 'Image' => '1', 'Type' => 'Story Advertisement' }

    it 'returns true when page has the specified type' do
      expect(page.include_type?('Story')).to be true
      expect(page.include_type?('Advertisement')).to be true
    end

    it 'returns false when page does not have the specified type' do
      expect(page.include_type?('FrontCover')).to be false
      expect(page.include_type?('Editorial')).to be false
    end
  end

  describe '#dimensions' do
    it 'returns hash with width and height when available' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600', 'ImageHeight' => '2400'

      expect(page.dimensions).to eq width: 1600, height: 2400
    end

    it 'returns nil values when dimensions are not set' do
      page = described_class.new 'Image' => '1'
      expect(page.dimensions).to eq(width: nil, height: nil)
    end

    it 'returns partial dimensions when only one is set' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600'
      expect(page.dimensions).to eq(width: 1600, height: nil)
    end
  end

  describe '#dimensions_available?' do
    it 'returns true when both dimensions are set' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600', 'ImageHeight' => '2400'
      expect(page.dimensions_available?).to be true
    end

    it 'returns false when dimensions are not set' do
      page = described_class.new 'Image' => '1'
      expect(page.dimensions_available?).to be false
    end

    it 'returns false when only one dimension is set' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600'
      expect(page.dimensions_available?).to be false
    end
  end

  describe '#aspect_ratio' do
    it 'calculates aspect ratio when dimensions are available' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600', 'ImageHeight' => '2400'
      expect(page.aspect_ratio).to eq(1600.0 / 2400.0)
    end

    it 'returns nil when dimensions are not available' do
      page = described_class.new 'Image' => '1'
      expect(page.aspect_ratio).to be_nil
    end

    it 'returns nil when height is zero' do
      page = described_class.new 'Image' => '1', 'ImageWidth' => '1600', 'ImageHeight' => '0'
      expect(page.aspect_ratio).to be_nil
    end
  end

  describe '#bookmarked?' do
    it 'returns true when bookmark is present' do
      page = described_class.new 'Image' => '1', 'Bookmark' => 'Chapter 1'
      expect(page.bookmarked?).to be true
    end

    it 'returns false when bookmark is empty' do
      page = described_class.new 'Image' => '1', 'Bookmark' => ''
      expect(page.bookmarked?).to be false
    end

    it 'returns false when bookmark is not set' do
      page = described_class.new 'Image' => '1'
      expect(page.bookmarked?).to be false
    end
  end

  describe '#to_h' do
    let(:full_page) do
      described_class.new(
        'Image' => '5', 'Type' => 'Story', 'DoublePage' => 'true',
        'ImageSize' => '1024000', 'Key' => 'page-key', 'Bookmark' => 'Important Scene',
        'ImageWidth' => '1600', 'ImageHeight' => '2400'
      )
    end

    it 'returns hash representation of page' do
      expected = {
        image: 5, type: 'Story', double_page: true, image_size: 1_024_000,
        key: 'page-key', bookmark: 'Important Scene', image_width: 1600, image_height: 2400
      }

      expect(full_page.to_h).to eq expected
    end
  end

  describe '#to_xml_attributes' do
    let(:xml_page) do
      described_class.new(
        'Image' => '5', 'Type' => 'FrontCover', 'DoublePage' => 'true',
        'ImageSize' => '1024000', 'Key' => 'cover', 'Bookmark' => 'Start',
        'ImageWidth' => '1600', 'ImageHeight' => '2400'
      )
    end

    it 'returns XML attributes hash with non-default values' do
      expected = {
        'Image' => '5', 'Type' => 'FrontCover', 'DoublePage' => 'true',
        'ImageSize' => '1024000', 'Key' => 'cover', 'Bookmark' => 'Start',
        'ImageWidth' => '1600', 'ImageHeight' => '2400'
      }

      expect(xml_page.to_xml_attributes).to eq expected
    end

    it 'omits default values from XML attributes' do
      page = described_class.new 'Image' => '0'

      expect(page.to_xml_attributes).to eq('Image' => '0')
    end
  end

  describe '#to_s' do
    it 'returns basic string representation' do
      page = described_class.new 'Image' => '5'
      expect(page.to_s).to eq('Page 5')
    end

    it 'includes type when not default' do
      page = described_class.new 'Image' => '5', 'Type' => 'FrontCover'
      expect(page.to_s).to include('Page 5')
      expect(page.to_s).to include('Type: FrontCover')
    end

    it 'includes double page indicator' do
      page = described_class.new 'Image' => '5', 'DoublePage' => 'true'
      expect(page.to_s).to include('Double')
    end

    it 'includes bookmark when present' do
      page = described_class.new 'Image' => '5', 'Bookmark' => 'Chapter Start'
      expect(page.to_s).to include('Bookmark: Chapter Start')
    end
  end

  describe '#inspect' do
    it 'returns detailed inspection string' do
      page = described_class.new 'Image' => '5', 'Type' => 'Story'
      expect(page.inspect).to start_with('#<ComicInfo::Page')
      expect(page.inspect).to include('Page 5')
    end
  end

  describe 'equality and hashing' do
    let(:first_page) do
      described_class.new(
        'Image'       => '1',
        'Type'        => 'Story',
        'DoublePage'  => 'false',
        'ImageSize'   => '100000',
        'Key'         => 'key1',
        'Bookmark'    => 'bookmark1',
        'ImageWidth'  => '1600',
        'ImageHeight' => '2400'
      )
    end

    let(:duplicate_page) do
      described_class.new(
        'Image'       => '1',
        'Type'        => 'Story',
        'DoublePage'  => 'false',
        'ImageSize'   => '100000',
        'Key'         => 'key1',
        'Bookmark'    => 'bookmark1',
        'ImageWidth'  => '1600',
        'ImageHeight' => '2400'
      )
    end

    let(:different_page) do
      described_class.new(
        'Image' => '2',
        'Type'  => 'Story'
      )
    end

    describe '#==' do
      it 'returns true for pages with identical attributes' do
        expect(first_page == duplicate_page).to be true
        expect(first_page.eql?(duplicate_page)).to be true
      end

      it 'returns false for pages with different attributes' do
        expect(first_page == different_page).to be false
        expect(first_page.eql?(different_page)).to be false
      end

      it 'returns false when comparing to non-Page object' do
        expect(first_page == 'not a page').to be false
      end
    end

    describe '#hash' do
      it 'returns same hash for equal pages' do
        expect(first_page.hash).to eq duplicate_page.hash
      end

      it 'returns different hash for different pages' do
        expect(first_page.hash).not_to eq different_page.hash
      end
    end
  end

  describe 'error handling' do
    it 'validates comic page type enum values' do
      expect do
        described_class.new 'Image' => '1', 'Type' => 'InvalidType'
      end.to raise_error(ComicInfo::Errors::InvalidEnumError)
    end

    it 'handles negative image size gracefully' do
      page = described_class.new 'Image' => '1', 'ImageSize' => '-1000'
      expect(page.image_size).to eq 0 # Default value for negative sizes
    end

    it 'raises error for invalid integer attributes' do
      expect do
        described_class.new 'Image' => '1', 'ImageSize' => 'not_a_number'
      end.to raise_error(ComicInfo::Errors::TypeCoercionError)
    end
  end

  describe 'XML schema compliance' do
    it 'validates against ComicPageType enum' do
      valid_types = %w[
        FrontCover InnerCover Roundup Story Advertisement
        Editorial Letters Preview BackCover Other Deleted
      ]

      valid_types.each do |type|
        expect do
          described_class.new 'Image' => '1', 'Type' => type
        end.not_to raise_error
      end
    end

    it 'handles space-separated type lists' do
      page = described_class.new 'Image' => '1', 'Type' => 'Story Advertisement Editorial'
      expect(page.types).to eq(%w[Story Advertisement Editorial])
      page.types.each do |type|
        expect(page.include_type?(type)).to be true
      end
    end
  end
end
