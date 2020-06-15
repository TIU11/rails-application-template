# frozen_string_literal: true

module DateTimeHelper

  # Display brief date with full date available as a tooltip.
  # - today: "11:32pm"
  # - this year: "25 Jan"
  # - older: "Dec 2011"
  # Usage: <%= readable_updated_at(updated_at, zone: true) %>
  def readable_date(date, zone: false, tag: :span)
    return if date.nil?

    format = if date.today? && date.acts_like?(:time)
               zone ? :time_with_zone : :time
             elsif date.year == Time.zone.today.year
               :day_and_month
             else
               :month_and_year
             end

    content_tag tag, I18n.localize(date, format: format), title: date.to_s(:long), data: { toggle: 'tooltip' }
  end

  # Cases:
  # * 1 - 59 seconds
  # * 1 - 59 minutes
  # * 1 hour
  # * 1.1 - 9.9 hours
  # * 10 - 23 hours
  # * 1 day
  # * 1.1 - 6.9 days
  # * 1 week
  # * 1.1 - infinity weeks
  #
  # TODO: consider using or drying this up along these lines:
  # https://github.com/hpoydar/chronic_duration/blob/master/lib/chronic_duration.rb
  # http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-distance_of_time_in_words
  # rubocop:disable all
  def duration_text(duration_in_seconds)
    return if duration_in_seconds.nil?
    seconds = duration_in_seconds
    minutes = seconds / 60
    hours = minutes / 60
    days = hours / 24
    weeks = days / 7

    if weeks > 1
      "#{weeks} weeks"
    elsif weeks > 0
      "#{weeks} week"
    elsif days > 1
      "#{days} days"
    elsif days > 0
      tenths = (seconds % 86_400 / 8640)
      "#{days}.#{tenths} days"
    elsif hours > 1
      "#{hours} hours"
    elsif hours > 0
      tenths = (seconds % 3600 / 360)
      "#{hours}.#{tenths} hours"
    elsif minutes > 1
      "#{minutes} minutes"
    elsif minutes > 0
      tenths = (seconds % 60 / 6)
      "#{minutes}.#{tenths} minutes"
    elsif seconds > 1
      "#{seconds} seconds"
    else
      "#{seconds} seconds"
    end
  end
  # rubocop:enable all

  def duration_span(duration_in_seconds, title_units = :seconds)
    title_duration = convert_seconds(duration_in_seconds, title_units)
    title = "#{title_duration} #{title_units}"
    tag.span duration_text(duration_in_seconds), title: title, data: { toggle: 'tooltip' }
  end

  def convert_seconds(duration_in_seconds, to = :minutes)
    duration_in_seconds / { seconds: 1, minutes: 60, hours: 3600, days: 86_400, weeks: 604_800 }[to]
  end

end
