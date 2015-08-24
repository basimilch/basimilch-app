# DOC: http://guides.rubyonrails.org/action_mailer_basics.html
class ApplicationMailer < ActionMailer::Base
  default from: "noreply@basimil.ch"
  layout 'mailer'
end
