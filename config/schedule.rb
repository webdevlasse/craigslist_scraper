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

set :output, "/Users/apprentice/Dropbox/craigslist_scraper/cron_log.log"
env :PATH, '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/Users/apprentice/.rvm/rubies/ruby-1.9.3-p194/bin/ruby:/Users/apprentice/Dropbox/craigslist_scraper'

every 1.day, :at => '09:27 am' do
  command "cd /Users/apprentice/Dropbox/craigslist_scraper/; /Users/apprentice/.rvm/rubies/ruby-1.9.3-p194/bin/ruby email_init.rb"
end