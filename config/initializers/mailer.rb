# Source: https://coderwall.com/p/qtsxug/
#                          prefix-all-emails-with-application-name-and-rails-env
class AddAppPrefixToEmailSubject
  EMAIL_PREFIX = 'basimilch'

  def self.delivering_email(mail)
    mail.subject.prepend(email_prefix)
  end

  def self.email_prefix
    prefixes = []
    prefixes << EMAIL_PREFIX
    prefixes << Rails.env.upcase unless Rails.env.production?
    if env_prefix = ENV['EMAIL_SUBJECT_PREFIX']
      prefixes << env_prefix
    end
    "[#{prefixes.join(' ')}] "
  end
end
ActionMailer::Base.register_interceptor(AddAppPrefixToEmailSubject)