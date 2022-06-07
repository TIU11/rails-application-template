# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :monday, at: '5:00 am' do
  rake "-s sitemap:refresh"
end

# Environment-specific crons
# - https://www.everclimb.co/snippets/how-to-run-whenever-cron-jobs-for-a-specific-environment
#
# ## Production ##
# every 1.month, at: 'start of the month at 8am', roles: [:production_cron] do
#   runner "ExampleJob.perform_later"
# end
#
# ## Demo ##
# # use one time runs for use on demo so it does not bug developers
# # exact run once raw cron syntax, use this site for ease:
# # - https://crontab.guru/#15_11_14_12_*
# # edit on demo server with sudo crontab -e -u www-data
# every '45 10 16 12 *', roles: [:demo_cron] do
#   runner "ExampleJob.perform_later"
# end
