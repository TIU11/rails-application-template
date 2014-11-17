module DateTimeHelper

  # Display brief date with full date available as a tooltip.
  # - today: "11:32"
  # - this year: "25 Jan"
  # - older: "Dec 2011"
  # Usage: <%= readable_updated_at(updated_at) %>
  def readable_date(date)
    return if date.nil?
    if date > Date.today
      "<span title=\"#{date.to_formatted_s(:long)}\">#{date.to_s(:time)}</span>".html_safe
    elsif date > Date.today.at_beginning_of_year
      "<span title=\"#{date.to_formatted_s(:long)}\">#{date.to_s(:day_and_month)}</span>".html_safe
    else
      "<span title=\"#{date.to_formatted_s(:long)}\">#{date.to_s(:month_and_year)}</span>".html_safe
    end
  end

  # Cases:
  # * 1-59 seconds
  # * 1-59 minutes
  # * 1 hour
  # * 1.1-9.9 hours
  # * 10-23 hours
  # * 1 day
  # * 1.1-6.9 days
  # * 1 week
  # * 1.1-∞ weeks
  #
  # TODO: consider using or drying this up along these lines:
  # https://github.com/hpoydar/chronic_duration/blob/master/lib/chronic_duration.rb
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
      tenths = (seconds % 86400 / 8640)
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

end
