# frozen_string_literal: true

# NOTE: doesn't support beginless or endless ranges
class DateRange < Range
  def same_day?
    first.to_date == last.to_date
  end

  def same_month?
    same_year? && first.month == last.month
  end

  def same_year?
    first.year == last.year
  end

  # Human-friendly date range representation, much like that of Google Calendar.
  #
  # Examples:
  #     May 1
  #     May 1 - 12
  #     May 1 - 12, 2019
  #     May 1 - June 12
  #     May 1 - June 12, 2019
  #     May 1, 2019 - January 1, 2020
  def to_s
    format_strings.then do |strs|
      [
        first.strftime(strs[0]),
        strs[1] && last.strftime(strs[1])
      ].compact.join(' - ')
    end
  end

  # An ActiveSupport::Duration for this range, calculated in years, months and days.
  #
  # NOTE: Avoids a simple difference because months and years have variable length (e.g. leap year).
  # So, not this: ActiveSupport::Duration.build(last.end_of_day - first.beginning_of_day, only: [:weeks, :days])
  def duration
    ends = last + 1 # inclusive (tomorrow - today = 2 days)
    (ends.year - first.year).years +
      (ends.month - first.month).months +
      (ends.day - first.day).days
  end

  private

    # Calulate the date format(s) that represents this range.
    def format_strings
      if same_day?
        ["%B %-d#{', %Y' if first.year != Time.zone.today.year}"]
      elsif same_month?
        ["%B %-d",
         "%-d#{', %Y' if last.year != Time.zone.today.year}"]
      elsif same_year?
        ["%B %-d",
         "%B %-d#{', %Y' if last.year != Time.zone.today.year}"]
      else
        ["%B %-d, %Y", "%B %-d, %Y"]
      end
    end

end
