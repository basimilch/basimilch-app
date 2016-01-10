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


# SOURCE: http://renderedtext.com/blog/2012/04/27/filtering-emails-on-staging/
class RecipientWhitelistInterceptor

  def self.delivering_email(message)
    whitelist = ENV['EMAIL_RECIPIENTS_WHITELIST']
    return unless whitelist
    ActionMailer::Base.logger.info "Checking email recipients against whitelist:"
    original_recipients = message.to
    whitelist_regexp    = regex_for_whitelist(whitelist)
    allowed_recipients  = original_recipients.select do |address|
      allowed_address? address, whitelist_regexp
    end
    ActionMailer::Base.logger.info " - Whitelist: #{whitelist.inspect}"
    ActionMailer::Base.logger.info " - Whitelist Regexp: #{whitelist_regexp.inspect}"
    ActionMailer::Base.logger.info " - Original recipients: #{original_recipients.inspect}"
    ActionMailer::Base.logger.info " - Allowed recipients: #{allowed_recipients.inspect}"
    message.to = allowed_recipients
    if message.to.empty?
      ActionMailer::Base.logger.info "Email will not be delivered."
      message.perform_deliveries = false
    end
  end

  private
    def self.regex_for_whitelist(whitelist)
      email_addresses = whitelist.split(',').map do |address|
        address.strip.gsub(/(\+.*:?)?@gmail.com/, "(\\\\+.*:?)?@gmail.com")
      end
      Regexp.new("^(#{email_addresses.join("|")}:?)$")
    end
    def self.allowed_address?(address, whitelist_regexp)
      address.match(whitelist_regexp)
    end
end
ActionMailer::Base.register_interceptor(RecipientWhitelistInterceptor)
