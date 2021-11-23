# frozen_string_literal: true

module DateRangeHelper
  # Shows date once, unless range starts and ends on different days.
  # => "January 1, 2018 9:30am - 12:30pm"
  # => "January 1, 2018 9:30am - January 2, 2018 12:30pm"
  # TODO: wrap times in :span? show full timestamp in tooltip
  # TODO: add %A full weekday 'Monday'
  # TODO: January 1 - 3 (no year on same year, no time for full day)
  def display_range(range)
    # Read range when given an ApplicationRecord object
    range = range.range if range.is_a? ApplicationRecord

    return if range.nil?
    raise ArgumentError, 'must be provide times' unless range.first.respond_to? :min
    return format_time(range.first, date: true, meridian: true) if same_time?(range)

    first = format_time(range.first, date: true, meridian: !same_meridian?(range))
    last = format_time(range.last, date: !same_day?(range), meridian: true)

    "#{first} - #{last}"
  end

  def time_range(range)
    # Read range when given an ApplicationRecord object
    range = range.range if range.is_a? ApplicationRecord

    return if range.nil? || !same_day?(range)
    return format_time(range.first, meridian: true) if same_time?(range)

    first = format_time(range.first, meridian: !same_meridian?(range))
    last = format_time(range.last, meridian: true)

    "#{first} - #{last}"
  end

  # May 1 - 12
  # May 1 - 12, 2019
  # May 1 - June 12
  # May 1 - June 12, 2019
  # May 1, 2019 - January 1, 2020
  def date_range(range)
    # Read range when given an ApplicationRecord object
    range = range.range if range.is_a? ApplicationRecord
    return if range.nil?

    tag.span DateRange.new(range.first, range.last).to_s,
             title: "#{range.first.to_s(:long)} - #{range.last.to_s(:long)}"
  end

  private

    def format_time(time, date: false, meridian: true)
      format_string = +'%-I'
      format_string << ':%M' unless time.min.zero?
      format_string << '%P' if meridian
      format_string.prepend('%B %-d, %Y ') if date

      time.strftime(format_string)
    end

    def format_date(date)
      date.year == Time.zone.today.year ? date.strftime('%B %-d') : date.strftime('%B %-d, %Y')
    end

    def same_time?(range)
      range.first == range.last
    end

    def same_day?(range)
      range.first.to_date == range.last.to_date
    end

    def same_month?(range)
      same_year?(range) && range.first.month == range.last.month
    end

    def same_year?(range)
      range.first.year == range.last.year
    end

    def same_meridian?(range)
      same_day?(range) && (range.first.hour < 12) == (range.last.hour < 12)
    end
end
