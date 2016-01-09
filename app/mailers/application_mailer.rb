# DOC: http://guides.rubyonrails.org/action_mailer_basics.html
class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_DEFAULT_FROM_ADDRESS']
  layout 'mailer'
end
