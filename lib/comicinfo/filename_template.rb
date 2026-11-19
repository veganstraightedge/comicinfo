require_relative 'enums'

module ComicInfo
  # Fills in a file name template, such as "{series} #{number} ({year})", from an issue.
  #
  # A value the issue lacks is left out, along with decoration that would be left empty around it:
  # "Saga # ()" becomes "Saga". "/" and ":" in a value become "-", since they cannot be part of a
  # file name. Anything else in the template, including a {name} that is not a token, is kept as
  # written. The result has no file extension.
  class FilenameTemplate
    # The names #filename fills in, written in a template as {name}.
    TOKENS = %w[number publisher series title volume year].freeze

    # The names #page_filename fills in: TOKENS and page.
    PAGE_TOKENS = [*TOKENS, 'page'].freeze

    EMPTY_DECORATION = ['()', '[]'].freeze

    def initialize template
      @template = template.to_s
    end

    # A file name for the issue.
    #
    # Write {number:3} to pad the issue number with zeros to that many digits (1 to 99). Only the
    # whole number it starts with is padded: "1.5" becomes "001.5" and "12AU" becomes "012AU".
    def filename issue
      fill template, issue
    end

    # A file name for one of the issue's page images.
    #
    # {page} is the page number, and {page:3} pads it with zeros to that many digits (1 to 99).
    # Page files are read in name order, so the result always keeps pages apart and in order:
    # the page number is at least as wide as the page count, a template with no page number gets
    # one appended after "_", and a name that would be empty is the page number alone.
    # "/" and ":" anywhere in the result become "-".
    def page_filename issue, page:, of:
      minimum_width = [page, of].max.to_s.length
      number        = zero_padded page.to_s, minimum_width
      numbered      = fill_padded('page', number, template).gsub('{page}', number)
      name          = fill numbered, issue

      complete = if numbered != template then name
                 elsif name.empty?       then number
                 else
                   "#{name}_#{number}"
                 end

      complete.tr '/:', '-'
    end

    private

    attr_reader :template

    def fill text, issue
      name = fill_padded 'number', value(issue, 'number'), text
      TOKENS.each { name = name.gsub("{#{it}}", value(issue, it)) }
      tidy name
    end

    # Fills in each {token:width} with the value padded to that width, leaving one whose width is
    # not 1 to 99 as written.
    def fill_padded token, value, text
      text.gsub(/\{#{token}:(\d{1,2})\}/) do |written|
        width = Regexp.last_match(1).to_i
        width.zero? ? written : zero_padded(value, width)
      end
    end

    # Pads the whole number the value starts with: "1.5" to "001.5" for a width of 3.
    def zero_padded value, width
      whole = value[/\A\d+/]
      return value if whole.nil? || whole.length >= width

      ('0' * (width - whole.length)) + value
    end

    def value issue, token
      raw = case token
            when 'number'    then issue.number
            when 'publisher' then issue.publisher
            when 'series'    then issue.series
            when 'title'     then issue.title
            when 'volume'    then integer issue.volume
            when 'year'      then integer issue.year
            end

      raw.to_s.tr('/:', '-').strip
    end

    def integer value
      value == Enums::DEFAULT_INTEGER ? nil : value
    end

    # Removes decoration left empty by missing values, then collapses whitespace.
    def tidy name
      tidied = EMPTY_DECORATION.reduce(name) { |text, empty| text.gsub empty, '' }
      tidied.split.reject { it == '#' }.join ' '
    end
  end
end
