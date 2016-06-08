class User < ActiveRecord::Base

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common
  include HasPostalAddress

  INTERN_EMAIL_DOMAIN = '@basimil.ch'
  INTERN_EMAIL_DOMAIN_REGEXP = Regexp.new("^.*#{INTERN_EMAIL_DOMAIN}$")

  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#1c-basic-usage
  has_paper_trail ignore: [:updated_at, :last_seen_at, :seen_count]

  has_many :share_certificates
  has_many :job_signups
  has_many :job_signups_done_in_current_year,
            -> { merge(JobSignup.in_current_year.past.not_canceled)},
            foreign_key:  "user_id",
            class_name:   "JobSignup"

  has_many :jobs, -> { distinct.remove_order }, through: :job_signups

  has_one  :subscribership, -> { not_canceled }
  has_one  :subscription, through: :subscribership
  has_one  :depot, through: :subscription

  scope :by_id, -> { order(id: :asc) }
  scope :by_name, -> { order(last_name: :asc).order(first_name: :asc).by_id }
  scope :by_last_seen_online, -> { order(last_seen_at: :desc) }
  scope :admins, -> { by_name.where(admin: true) }
  scope :with_intern_email, -> { by_name.where('email ILIKE ?',
                                               '%' + INTERN_EMAIL_DOMAIN) }
  scope :recently_online, -> { where("last_seen_at > ?", 5.minutes.ago)
                                .by_last_seen_online }
  scope :emails, -> { pluck(:email) }

  # DOC: http://guides.rubyonrails.org/active_record_querying.html#conditions
  # DOC: http://www.postgresql.org/docs/current/static/functions-matching.html
  # If the search string contains several words, the corresponding `where`
  # clauses are ANDed.
  scope :search, ->(s) do
    return all if s.nil? || !s.is_a?(String)
    s.split(/\W/).inject(all) { |query, word|
      query.where("first_name ILIKE :contains_word OR" +
                           " last_name ILIKE :contains_word OR" +
                           " email ILIKE :contains_word OR" +
                           " id = :id",
                           contains_word: "%#{word}%",
                           id: word.to_i) }
    end

  scope :inactive, -> { by_name.where(activated: [nil, false], activation_sent_at: nil)}
  scope :pending_activation, -> { by_name.where(activated: [nil, false])
                      .by_name.where(User.arel_table[:activation_sent_at].not_eq(nil)) }
  scope :active, -> { by_last_seen_online.where(activated: true) }
  scope :stale, -> { by_name.where(User.arel_table[:last_seen_at].lt(STALE_THRESHOLD)) }

  scope :with_subscription, -> { by_name.joins(:subscribership) }
  scope :without_subscription, -> { by_name.where.not(
                                      id: Subscribership.subscribed_user_ids) }

  # Identify users with missing info:
  scope :without_tel, -> { by_name.where(User.arel_table[:tel_mobile]
                              .matches("%0000000")) }
  scope :without_email, -> { by_name.where(User.arel_table[:email]
                              .matches("%@example.org")) }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  ONLY_SPACES       = /\A\s*\z/

  STALE_THRESHOLD = 4.months.ago

  class Status < Enum
    enum :WAITING_LIST
  end

  attr_accessor :remember_token

  validates :status, inclusion: { in: Status.all }, allow_nil: true

  # Inspired from
  #   https://www.railstutorial.org/book/_single-page#sec-format_validation

  validates :email,       presence: true,
                          length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }
  before_validation :downcase_email

  before_validation :capitalize_first_name
  validates :first_name,  presence: true,
                          length: { maximum: 40 }

  before_validation :capitalize_last_name
  validates :last_name,   presence: true,
                          length: { maximum: 40 }

  # Source:
  #  http://guides.rubyonrails.org/active_record_validations.html#validates-each
  validates_each :tel_mobile, :tel_home, :tel_office do |record, attr, value|
    unless value.blank?
      # SOURCE: https://github.com/joost/phony_rails
      normalized_value = value.phony_normalized(default_country_code: 'CH')
      if value =~ /[[:alpha:]]/ or
         normalized_value.blank? or
         !Phony.plausible?(normalized_value)
        record.errors.add(attr, :improbable_phone)
      end
    end
  end
  before_save :normalize_tels

  validate :at_least_one_tel

  # NOTE: Used by rake task 'import_csv:users' to bypass the signup extra fields.
  attr_accessor :imported

  # DOC: http://guides.rubyonrails.org/active_record_validations.html#acceptance
  # SOURCE: http://stackoverflow.com/a/10748001
  validates :terms_of_service, acceptance: true, presence: true, on: :create,
            unless: :imported

  ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES = (1..4)
  attr_accessor :wanted_number_of_share_certificates
  validates :wanted_number_of_share_certificates, presence: true, on: :create,
            # NOTE: since this is a virtual attribute, Rails does not know the
            #       type of the value and 'inclusion: { in: ALLOWED_NUMBER... }'
            #       validation cannot be used. Compare with e.g.
            #       Depot#delivery_day: since its an real DB attribute of type
            #       integer it gets casted into a number and the
            #       'inclusion: { in: ... }' validation does work.
            #       The 'numericality' validation casts instead the value to a
            #       number automatically.
            # DOC: http://guides.rubyonrails.org/v4.2.6/active_record_validations.html#numericality
            numericality: {
    greater_than_or_equal_to: ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES.first,
    less_than_or_equal_to:    ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES.last
  },
            unless: :imported

  class WantedSubscriptionOptions < Enum
    enum :NO_SUBSCRIPTION
    enum :WAITING_LIST_FOR_SUBSCRIPTION
    enum :SHARE_WITH_USER_IN_WAITING_LIST
    enum :SHARE_WITH_USER_ALREADY_ACTIVE
  end
  attr_accessor :wanted_subscription
  validates :wanted_subscription, presence: true, on: :create,
            inclusion: { in: WantedSubscriptionOptions.all },
            unless: :imported

  def full_name
    "#{first_name} #{last_name}"
  end

  def formatted_tel(tel_type)
    if ! send("tel_#{tel_type}_changed?") || valid?
      raw_tel = send("tel_#{tel_type}") || ""
      # Source:
      #   https://github.com/floere/phony/blob/master/qed/format.md#options
      raw_tel.phony_formatted(normalize:  'CH',
                              format:   :international, # => "+41 76 111 11 11"
                              # format: :national,    # => "076 111 11 11"
                              spaces: ' ')
    end
  end

  # Returns the tel with national format if it's a swiss number (i.e. "0xx ..."
  # instead of "+41 xx..."). Otherwise it returns the number with the country
  # code.
  def formatted_tel_national(tel_type)
    formatted_tel   = formatted_tel(tel_type) || ''
    is_swiss_phone  = formatted_tel.remove_whitespace.swiss_phone_number?
    formatted_tel.phony_formatted(normalize: 'CH',
                            format: is_swiss_phone ? :national : :international,
                            spaces: ' ')
  end

  def tel_mobile_formatted
    formatted_tel(:mobile)
  end

  def tel_mobile_formatted_national
    formatted_tel_national(:mobile)
  end

  def tel_mobile_formatted=(value)
    self.tel_mobile = value
  end

  def tel_home_formatted
    formatted_tel(:home)
  end

  def tel_home_formatted_national
    formatted_tel_national(:home)
  end

  def tel_home_formatted=(value)
    self.tel_home = value
  end

  def tel_office_formatted
    formatted_tel(:office)
  end

  def tel_office_formatted_national
    formatted_tel_national(:office)
  end

  def tel_office_formatted=(value)
    self.tel_office = value
  end

  def tels
    tels = {}
    tels[:mobile] = tel_mobile_formatted if tel_mobile
    tels[:home]   = tel_home_formatted   if tel_home
    tels[:office] = tel_office_formatted if tel_office
    tels
  end

  # Updates the last_seen_at date with the current one.
  def seen
    assign_attributes(last_seen_at: Time.current)
    increment(:seen_count)
    save(validate: false)
  end

  # Remembers a user in the database for use in persistent sessions.
  # SOURCE: https://www.railstutorial.org/book/_single-page#code-user_model_remember
  def remember
    self.remember_token = User.new_token
    update_attributes!(remember_digest:  remember_token.digest,
                       remembered_since: Time.current)
  end

  def record_last_login(from: nil)
    update_attributes!(last_login_at:   Time.current,
                       last_login_from: from)
  end

  # Returns true if the given token matches the digest.
  # SOURCE: https://www.railstutorial.org/book/_single-page#code-generalized_authenticated_p
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    digest.is_digest_for? token
  end

  # Forgets a user.
  def forget
    update_attributes!(remember_digest:   nil,
                       remembered_since:  nil)
  end

  # Sends activation email.
  def send_activation_email
    update_attributes!(activation_sent_at: Time.current)
    UserMailer.account_activation(self).deliver_now
  end

  # Helper method to check if a user still has a placeholder email address.
  # This should only be the case for users manually imported in the initial
  # launch since new users cannot sign up without a valid email address.
  # However, admins can still create users without a valid email address.
  # Check the corresponding scope :without_email.
  def with_placeholder_email?
    email.match(/.*@example.org$/).to_b
  end

  # Sends job reminder email.
  def send_job_reminder(job)
    UserMailer.job_reminder(self, job).deliver_now
  end

  # Activates an account.
  def activate
    update_attributes!(activated:    true,
                       activated_at: Time.current)
  end

  def recently_online?
    last_seen_at && last_seen_at > 5.minutes.ago
  end

  def allowed_to_login?
    activated? || activation_sent_at
  end

  def never_logged_in?
    !activated?
  end

  def stale?
    last_seen_at && last_seen_at < STALE_THRESHOLD
  end

  def with_intern_email?
    email.match(INTERN_EMAIL_DOMAIN_REGEXP).to_b
  end

  def set_password(params_arg)
    update_attributes(params_arg
                        .require(:user)
                        .permit(:password, :password_confirmation))
  end

  # Returns an array of job_signups for this user and this year.
  # The array has a min length equal to the min number of jobs that
  # a user has to do, with 'nil' for the missing required signups.
  def current_year_job_signups
    min = JobSignup::MIN_NUMBER_PER_USER_PER_YEAR
    year_job_signups = job_signups.in_current_year.by_job_start_at
    (year_job_signups + [nil] * min).take([year_job_signups.size, min].max)
  end

  def count_of_jobs_done_this_year
    # NOTE: Using .to_a.count instead of .count directly on the collection
    #       allows to benefit from the preloading if
    #       .includes(:job_signups_done_in_current_year) is used.
    job_signups_done_in_current_year.to_a.count
  end

  def number_of_valid_share_certificates
    share_certificates.count
  end

  def to_s
    "User #{id.inspect}: #{full_name.inspect} <#{email}>" +
      "#{admin? ? ' (ADMIN)': ''}"
  end

  def to_html
    "#{full_name} (<a href='mailto:#{email}'><code>#{email}</code></a>)"
  end

  def attributes(include_virtual: false)
    super() + (include_virtual ? {
      terms_of_service: terms_of_service,
      wanted_number_of_share_certificates: wanted_number_of_share_certificates,
      wanted_subscription: wanted_subscription
    } : {})
  end

  # Class methods

  # Returns a random token.
  # SOURCE: https://www.railstutorial.org/book/_single-page#code-token_method
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Private methods

  private

    def normalize_tels
      self.tel_mobile = normalized_tel tel_mobile
      self.tel_home   = normalized_tel tel_home
      self.tel_office = normalized_tel tel_office
    end

    def normalized_tel(tel)
      unless tel.blank?
        tel.phony_normalized(default_country_code: 'CH')
      end
    end

    def at_least_one_tel
      if tel_mobile.blank? && tel_home.blank? && tel_office.blank?
        errors.add(:base, I18n.t("errors.messages.at_least_one_tel"))
      end
    end

    # Before filters

    def downcase_email
      self.email = email.try(:downcase)
    end

    def capitalize_first_name
      self.first_name = first_name.try(:titlecase)
    end

    def capitalize_last_name
      self.last_name = last_name.try(:titlecase)
    end
end
