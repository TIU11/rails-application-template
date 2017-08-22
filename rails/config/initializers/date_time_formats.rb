# Date and time formats

# Time
# See http://api.rubyonrails.org/classes/Time.html

Time::DATE_FORMATS[:time] = "%l:%M%P"           # 1:30p
Time::DATE_FORMATS[:month_and_year] = "%b %Y"   # Jan 2012
Time::DATE_FORMATS[:day_and_month] = "%b %e"    # Jan 5
Time::DATE_FORMATS[:default] = ->(date) { date.strftime("%-m/%-d/%Y %l:%M%P").strip } # 1/9/2012 1:03pm
Time::DATE_FORMATS[:long] = "%B %e, %Y %l:%M%P" # January 09, 2012 1:30pm

# Date
# See http://api.rubyonrails.org/classes/Date.html

Date::DATE_FORMATS[:default] = ->(date) { date.strftime("%-m/%-d/%Y").strip } # 1/9/2012
