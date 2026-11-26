module ComicInfo
  # One issue a metadata source found that might be the comic being looked up.
  #
  # It holds what a person needs to pick the right one from a list, and the source's own ID to
  # fetch the rest with the source's #issue. See doc/metadata-sources.md.
  #
  # - id: the source's ID for the issue
  # - heading: how the match is listed, such as "Saga (2012) #1"
  # - series: the series name, as the source writes it
  # - number: the issue number, as the source writes it
  # - cover_date: the cover date, as the source writes it, usually "2012-03-01"
  # - title: the issue's title
  # - details: more to tell matches apart, such as "Image · Cover date 2012-03-01"
  # - site_url: the issue's page on the source's site
  Match = Data.define :id, :heading, :series, :number, :cover_date, :title, :details, :site_url do
    def initialize id:, heading:, series:, cover_date: nil, details: nil, number: nil, site_url: nil, title: nil
      super
    end
  end
end
