require 'spec_helper'
require 'yaml'

RSpec.describe ComicInfo::FilenameCleaner do
  let(:test_cases) { YAML.load(fixture_file('filenames/test_cases.yaml'))['test_cases'] }

  describe '#clean' do
    context 'with fixture test cases' do
      it 'handles all test cases correctly' do
        test_cases.each do |test_case|
          cleaner = described_class.new(tags: test_case['tags'])
          result = cleaner.clean(test_case['input'])

          expect(result).to eq(test_case['expected']),
                            "Failed for '#{test_case['description']}': expected '#{test_case['expected']}' but got '#{result}'"
        end
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
