# DOC: https://devcenter.heroku.com/articles/scheduler

desc "This task is called by the Heroku scheduler add-on"

task :send_reminders_for_tomorrow_jobs => :environment do
  puts "Sending reminders for tomorrow's jobs (#{Date.tomorrow})..."
  tomorrow_jobs = Job.tomorrow
  if tomorrow_jobs.empty?
    puts " => no jobs scheduled for tomorrow"
    puts " => nothing sent"
    next
  else
    puts " => jobs found for tomorrow"
    tomorrow_jobs.each(&:send_reminders)
  end
  puts "Jobs reminders successfully sent."
end

task :send_daily_activity_report_to_admin => :environment do
  puts "Sending send daily activity report..."
  AdminMailer.daily_activity_report.deliver_now
  puts " => Daily activity report reminders successfully sent."
end
