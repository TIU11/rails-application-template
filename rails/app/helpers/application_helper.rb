module ApplicationHelper

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

end
