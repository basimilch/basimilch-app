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


# TODO: Fix where to place utils like this
# SOURCE: http://stackoverflow.com/questions/1068558/oo-design-in-rails-where-to-put-stuff
# SOURCE: http://stackoverflow.com/questions/2726934/where-to-put-reusable-methods-for-access-by-controllers-in-rails
# SOURCE: http://stackoverflow.com/questions/15318647/utility-classes-in-ruby-on-rails
class RegexpUtils

  # TODO: Gather here all regexps.

  # SOURCE: https://www.ruby-forum.com/topic/49046
  MATCH_EVERYTHING = Regexp.new('')
  MATCH_NOTHING    = Regexp.new('.^')

  # NOTE: According to the docs, \s only matches [ \t\r\n\f], i.e. it does not
  #       match e.g. non-breaking space (&nbsp). The POSIX character class
  #       [[:space:]] does match non-breaking space. This is relevant because
  #       in Heroku, space in ENV variables might be translated as &nbsp.
  # SOURCE: http://stackoverflow.com/a/13288542
  COMMA_SEPARATION = /[[:space:]]*,[[:space:]]*/
  MULTIPLE_COMMA_SEPARATION = /(?:[[:space:]]*,+[[:space:]]*)+/

  def self.regex_for_email_list(email_list)
    return nil            if email_list.nil?
    return MATCH_NOTHING  if email_list.strip.empty?
    email_addresses = email_list.split(COMMA_SEPARATION).map do |address|
      # Match all emails addresses of a domain, if only the domain is given
      # Match the + aliases for gmail addresses
      # TODO: If a gmail alias is explicitly given, consider matching only
      #       this alias, not the base email address or other aliases.
      address
        .strip
        .downcase
        .gsub(/([^+]+)(\+.*:?)?@gmail.com/,'\1(\\\\+.*:?)?@gmail.com')
        .gsub(/^(@\S+\.[a-z]{2,})$/, '\\S+\1')
    end
    Regexp.new("^(#{email_addresses.join("|")}:?)$")
  end
end


# SOURCE: http://renderedtext.com/blog/2012/04/27/filtering-emails-on-staging/
class RecipientWhitelistBlacklistInterceptor

  WHITELIST        = ENV['EMAIL_RECIPIENTS_WHITELIST']
  BLACKLIST        = ENV['EMAIL_RECIPIENTS_BLACKLIST']
  WHITELIST_REGEXP = RegexpUtils.regex_for_email_list(WHITELIST)
  BLACKLIST_REGEXP = RegexpUtils.regex_for_email_list(BLACKLIST)


  # Returns a new array containing all email addresses in the 'original_list'
  # array which are allowed given the current WHITELIST and BLACKLIST.
  #
  # NOTE: The meaning of 'nil' for whitelist and blacklist is the
  #       same: they are 'nil' when they have not been explicitly set
  #       up in an ENV variable and thus they have no influence on the
  #       allowed email filtering, i.e. they don't block any email
  #       addresses.
  #
  #       However they can be setup (i.e. they will not be 'nil') to
  #       an empty string (i.e. list && list.strip.empty?). In that
  #       case the meaning will differ. A not-nil but empty blacklist
  #       is the same than a 'nil' blacklist: it does not have any
  #       influence on the filtering of email addresses. However, a
  #       not-nil but empty whitelist has the contrary meaning: it
  #       blocks all addresses because none are in the allowed
  #       whitelist. This might be a bit confusing, and thus all this
  #       cases are checked in the tests for clarity.
  #
  #       Blacklist rules over whitelist, i.e. if an email address is
  #       both whitelisted and blacklisted it will be blocked.
  def self.select_allowed_addresses(original_list,
                                    whitelist_regexp: nil,
                                    blacklist_regexp: nil)
    (original_list || []).select do |address|
      address.match(whitelist_regexp || RegexpUtils::MATCH_EVERYTHING) &&
        !address.match(blacklist_regexp || RegexpUtils::MATCH_NOTHING)
    end
  end

  def self.delivering_email(message)
    return unless WHITELIST || BLACKLIST
    logger = ActionMailer::Base.logger
    logger.info "Checking email recipients against whitelist/blacklist:"
    original_recipients = {
      to:   message.to  || [],
      cc:   message.cc  || [],
      bcc:  message.bcc || []
    }
    allowed_recipients = {
      to:   select_allowed_recipients(message.to),
      cc:   select_allowed_recipients(message.cc),
      bcc:  select_allowed_recipients(message.bcc)
    }
    logger.info   " - Whitelist:        #{WHITELIST.inspect}"
    logger.debug  " - Whitelist Regexp: #{WHITELIST_REGEXP.inspect}"
    logger.info   " - Blacklist:        #{BLACKLIST.inspect}"
    logger.debug  " - Blacklist Regexp: #{BLACKLIST_REGEXP.inspect}"
    logger.info   " - Original recipients:  #{original_recipients.inspect}"
    logger.info   " - Allowed recipients:   #{allowed_recipients.inspect}"
    message.to  = allowed_recipients[:to]
    message.cc  = allowed_recipients[:cc]
    message.bcc = allowed_recipients[:bcc]
    if allowed_recipients.values.all?(&:empty?)
      logger.warn "Email will not be delivered"
      message.perform_deliveries = false
    elsif original_recipients == allowed_recipients
      logger.debug "Email will be delivered to all original recipients"
    else
      logger.warn "Email will be delivered but NOT to all original recipients"
    end
  end

  private

    def self.select_allowed_recipients(original_recipients)
      select_allowed_addresses original_recipients,
        whitelist_regexp: WHITELIST_REGEXP,
        blacklist_regexp: BLACKLIST_REGEXP
    end
end
ActionMailer::Base.register_interceptor(RecipientWhitelistBlacklistInterceptor)
