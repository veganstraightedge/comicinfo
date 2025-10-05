RSpec.describe ComicInfo do
  it 'has a version number' do
    expect(ComicInfo::VERSION).not_to be_nil
  end

  describe '.load' do
    context 'with a valid file path' do
      it 'loads a minimal ComicInfo.xml file' do
        comic = load_fixture 'valid_minimal.xml'

        expect(comic).to be_a ComicInfo::Issue
        expect(comic.title).to eq 'Minimal Comic'
        expect(comic.series).to eq 'Test Series'
        expect(comic.number).to eq '1'
      end

      it 'loads a complete ComicInfo.xml file with all fields' do
        comic = load_fixture 'valid_complete.xml'

        expect(comic).to be_a ComicInfo::Issue
        expect(comic.title).to eq 'The Amazing Spider-Man'
        expect(comic.series).to eq 'The Amazing Spider-Man'
        expect(comic.number).to eq '1'
        expect(comic.count).to eq 600
        expect(comic.volume).to eq 3
        expect(comic.pages).to be_an Array
        expect(comic.pages.length).to eq(12)
      end

      it 'raises an error when file does not exist' do
        expect do
          described_class.load 'non_existent_file.xml'
        end.to raise_error ComicInfo::Errors::FileError
      end

      it 'raises an error when file contains invalid XML' do
        file_path = File.join(__dir__, 'fixtures', 'invalid_xml.xml')
        expect do
          described_class.load file_path
        end.to raise_error(ComicInfo::Errors::ParseError)
      end
    end

    context 'with XML string content' do
      it 'loads from XML string' do
        xml_content = fixture_file 'valid_minimal.xml'
        comic = described_class.load xml_content

        expect(comic).to be_a ComicInfo::Issue
        expect(comic.title).to eq 'Minimal Comic'
      end

      it 'raises an error with malformed XML string' do
        malformed_xml = '<ComicInfo><Title>Test</Title>'
        expect do
          described_class.load malformed_xml
        end.to raise_error ComicInfo::Errors::ParseError
      end

      it 'handles empty XML string' do
        expect do
          described_class.load ''
        end.to raise_error ComicInfo::Errors::ParseError
      end
    end

    context 'with nil or invalid input' do
      it 'raises an error with nil input' do
        expect do
          described_class.load nil
        end.to raise_error ComicInfo::Errors::ParseError
      end

      it 'raises an error with non-string, non-file input' do
        expect do
          described_class.load 123
        end.to raise_error ComicInfo::Errors::ParseError
      end
    end
  end

  describe 'convenience method delegation' do
    it 'delegates to ComicInfo::Issue.load' do
      file_path = File.join(__dir__, 'fixtures', 'valid_minimal.xml')
      allow(ComicInfo::Issue).to receive(:load).and_call_original

      comic = described_class.load file_path

      expect(comic).to be_a ComicInfo::Issue
      expect(ComicInfo::Issue).to have_received(:load).with file_path
    end
  end

  describe 'module structure' do
    it 'defines the correct autoloaded constants' do
      expect(defined?(ComicInfo::Issue)).to be_truthy
      expect(defined?(ComicInfo::Page)).to be_truthy
      expect(defined?(ComicInfo::Enums)).to be_truthy
      expect(defined?(ComicInfo::Errors)).to be_truthy
    end

    it 'has the Error base class' do
      expect(ComicInfo::Error).to be < StandardError
    end
  end
end
