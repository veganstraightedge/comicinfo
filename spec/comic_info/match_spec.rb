RSpec.describe ComicInfo::Match do
  it 'holds what a source found' do
    found = described_class.new id:         '38475',
                                heading:    'Saga (2012) #1',
                                series:     'Saga',
                                number:     '1',
                                cover_date: '2012-03-01',
                                title:      'Chapter One',
                                details:    'Image · Cover date 2012-03-01',
                                site_url:   'https://comicvine.gamespot.com/saga-1/4000-38475/'

    expect(found.id).to eq '38475'
    expect(found.heading).to eq 'Saga (2012) #1'
    expect(found.series).to eq 'Saga'
    expect(found.number).to eq '1'
    expect(found.cover_date).to eq '2012-03-01'
    expect(found.title).to eq 'Chapter One'
    expect(found.details).to eq 'Image · Cover date 2012-03-01'
    expect(found.site_url).to eq 'https://comicvine.gamespot.com/saga-1/4000-38475/'
  end

  it 'needs only an id, a heading and a series' do
    found = described_class.new id: '1', heading: 'Saga #1', series: 'Saga'

    expect(found.number).to be_nil
    expect(found.cover_date).to be_nil
    expect(found.title).to be_nil
    expect(found.details).to be_nil
    expect(found.site_url).to be_nil
  end

  it 'equals another match with the same values' do
    found = described_class.new id: '1', heading: 'Saga #1', series: 'Saga'

    expect(found).to eq described_class.new(id: '1', heading: 'Saga #1', series: 'Saga')
  end
end
