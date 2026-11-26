RSpec.describe ComicInfo::Issue do
  describe '#rank' do
    def match id, series:, cover_date: nil
      ComicInfo::Match.new id:, heading: "#{series} #1", series:, cover_date:
    end

    it 'ranks a series named exactly as the issue’s first, ignoring case and surrounding space' do
      issue   = load_fixture 'filename/series_only.xml'
      matches = [match('1', series: 'Saga Deluxe'), match('2', series: ' saga ')]

      expect(issue.rank(matches).map(&:id)).to eq %w[2 1]
    end

    it 'ranks a cover dated in the issue’s year next' do
      issue   = load_fixture 'filename/series_year.xml'
      matches = [
        match('1', series: 'Saga', cover_date: '2018-01-01'),
        match('2', series: 'Saga Deluxe', cover_date: '2012-03-01'),
        match('3', series: 'Saga', cover_date: '2012-03-01')
      ]

      expect(issue.rank(matches).map(&:id)).to eq %w[3 1 2]
    end

    it 'keeps the source’s order otherwise' do
      issue   = load_fixture 'filename/series_only.xml'
      matches = [match('1', series: 'Saga'), match('2', series: 'Paper Girls'), match('3', series: 'Saga')]

      expect(issue.rank(matches).map(&:id)).to eq %w[1 3 2]
    end

    it 'counts the cover date for nothing without a year' do
      issue   = load_fixture 'filename/series_only.xml'
      matches = [match('1', series: 'Saga', cover_date: '2018-01-01'), match('2', series: 'Saga')]

      expect(issue.rank(matches).map(&:id)).to eq %w[1 2]
    end

    it 'counts the series for nothing without one' do
      issue   = load_fixture 'pages/count_only.xml'
      matches = [match('1', series: ''), match('2', series: 'Saga')]

      expect(issue.rank(matches).map(&:id)).to eq %w[1 2]
    end

    it 'is empty for no matches' do
      expect(load_fixture('filename/series_only.xml').rank([])).to be_empty
    end
  end
end
