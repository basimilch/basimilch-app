class User < ActiveRecord::Base

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common

  INTERN_EMAIL_DOMAIN = '@basimil.ch'
  INTERN_EMAIL_DOMAIN_REGEXP = Regexp.new("^.*#{INTERN_EMAIL_DOMAIN}$")

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at, :last_seen_at]

  has_many :share_certificates
  has_many :job_signups
  has_many :jobs, -> {distinct}, through: :job_signups

  scope :by_name, -> { order(last_name: :asc).order(id: :asc) }
  scope :by_id, -> { order(id: :asc) }
  scope :admins, -> { by_name.where(admin: true) }
  scope :with_intern_email, -> { by_name.where('email ILIKE ?',
                                               '%' + INTERN_EMAIL_DOMAIN) }
  # DOC: http://www.informit.com/articles/article.aspx?p=2220311
  scope :working_tomorrow, -> { by_name.joins(:jobs).merge(Job.tomorrow).distinct }
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
  scope :active, -> { by_name.where(activated: true) }
  scope :stale, -> { by_name.where(User.arel_table[:last_seen_at].lt(STALE_THRESHOLD)) }

  # Identify users with missing info:
  scope :without_tel, -> { by_name.where(User.arel_table[:tel_mobile]
                              .matches("%0000000")) }
  scope :without_email, -> { by_name.where(User.arel_table[:email]
                              .matches("%@example.org")) }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_SWISS_POSTAL_CODE_REGEX = /\A\d{4}\z/ # The 'CH-' part is not expected.
  ONLY_SPACES       = /\A\s*\z/

  STALE_THRESHOLD = 4.months.ago

  attr_accessor :remember_token

  # NOTE: A word of caution: 'after_initialize' means after the Ruby
  # initialize. Hence it is run every time a record is loaded from the
  # database and used to create a new model object in memory Source:
  # http://stackoverflow.com/a/4576026
  after_initialize :default_values

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

  validates :postal_address,  presence: true
  validates :postal_address_supplement, length: { maximum: 50 }
  validates :postal_code,     presence: true,
                              format: { with: VALID_SWISS_POSTAL_CODE_REGEX }
  validates :city,            presence: true
  validates :country,         presence: true

  # Source:
  #  http://guides.rubyonrails.org/active_record_validations.html#validates-each
  validates_each :tel_mobile, :tel_home, :tel_office do |record, attr, value|
    unless value.blank?
      # Source: https://github.com/joost/phony_rails
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
            numericality: {
    greater_than_or_equal_to: ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES.first,
    less_than_or_equal_to:    ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES.last
  },
            unless: :imported

  # DOC: http://ruby-doc.org/core-2.2.4/doc/syntax/literals_rdoc.html#label-Percent+Strings
  ALLOWED_WANTED_SUBSCRIPTION_OPTIONS = %w(
    no_subscription
    waiting_list_for_subscription
    share_with_user_in_waiting_list
    share_with_user_already_active
  )
  attr_accessor :wanted_subscription
  validates :wanted_subscription, presence: true, on: :create,
            inclusion: { in: ALLOWED_WANTED_SUBSCRIPTION_OPTIONS },
            unless: :imported

  validate :correct_full_postal_address

  geocoded_by :full_postal_address

  def full_postal_address(separator: ', ')
    [postal_address, postal_code, city, country].compact.join(separator)
  end

  def coordinates_map_url
    "http://maps.google.com/maps?q=#{latitude},#{longitude}" if geocoded?
  end

  def postal_address_map_url
    if geocoded?
      q = full_postal_address(separator: '+').replace_spaces_with("+")
      "http://maps.google.com/maps?q=#{q}"
    end
  end

  def correct_full_postal_address
    if postal_address.blank? ||
       postal_code.blank?    ||
       city.blank?           ||
       country.blank?
      errors.add(:base, I18n.t("errors.messages.uncomplete_postal_address"))
      return
    end
    unless postal_address_changed? ||
           postal_code_changed?    ||
           city_changed?           ||
           country_changed?
      return
    end
    initial_number_of_errors = errors.count
    result = Geocoder.search(full_postal_address).first
    unless result && result.route.present? && result.postal_code.present?
      errors.add(:base, I18n.t("errors.messages.unrecornised_postal_address"))
      return
    end
    result_postal_address = "#{result.route} #{result.street_number}".strip
    self.postal_address = postal_address.strip
    if postal_address != result_postal_address
      errors.add(:postal_address,
                 I18n.t("errors.messages.unrecornised_and_replaced",
                        original:  postal_address,
                        corrected: result_postal_address))
      self.postal_address = result_postal_address
    end
    self.postal_code = postal_code.strip
    if postal_code != result.postal_code
      errors.add(:postal_code,
                 I18n.t("errors.messages.unrecornised_and_replaced",
                        original:  postal_code,
                        corrected: result.postal_code))
      self.postal_code = result.postal_code
    end
    self.city = city.strip
    if city != result.city
      errors.add(:city,
                 I18n.t("errors.messages.unrecornised_and_replaced",
                        original:  city,
                        corrected: result.city))
      self.city = result.city
    end
    self.country = country.strip
    if country != result.country
      errors.add(:country,
                 I18n.t("errors.messages.unrecornised_and_replaced",
                        original:  country,
                        corrected: result.country))
      self.country = result.country
    end
    if errors.count == initial_number_of_errors
      # Manually geocode the user, to prevent a second API request
      self.latitude       = result.latitude
      self.longitude      = result.longitude
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def formatted_tel(tel_type)
    if ! send("tel_#{tel_type}_changed?") || valid?
      raw_tel = send("tel_#{tel_type}") || ""
      # Source:
      #   https://github.com/floere/phony/blob/master/qed/format.md#options
      raw_tel.phony_formatted(:normalize => 'CH',
                              :format => :international, # => "+41 76 111 11 11"
                              # :format => :national,    # => "076 111 11 11"
                              :spaces => ' ')
    end
  end

  def tel_mobile_formatted
    formatted_tel(:mobile)
  end

  def tel_mobile_formatted=(value)
    self.tel_mobile = value
  end

  def tel_home_formatted
    formatted_tel(:home)
  end

  def tel_home_formatted=(value)
    self.tel_home = value
  end

  def tel_office_formatted
    formatted_tel(:office)
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
    update_attribute(:last_seen_at, Time.current)
  end

  # Remembers a user in the database for use in persistent sessions.
  # Source: https://www.railstutorial.org/book/_single-page
  #                                                    #code-user_model_remember
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
  # Source: https://www.railstutorial.org/book/_single-page
  #                                            #code-generalized_authenticated_p
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

  # Returns an array of jobs for which this user has signup this year.
  # The array has a min length equal to the min number of jobs that
  # a user has to do, with 'nil' for the missing required signups.
  def current_year_jobs
    min = JobSignup::MIN_NUMBER_PER_USER_PER_YEAR
    jobs = job_signups.in_current_year.map(&:job)
    (jobs + [nil] * min).take([jobs.count, min].max)
  end

  def to_s
    "User #{id.inspect}: #{full_name.inspect} <#{email}>"
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
  # Source: https://www.railstutorial.org/book/_single-page#code-token_method
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Private methods

  private

    def default_values
      # NOTE: To learn about the or-equals (i.e. '||=') form, see
      #       https://www.railstutorial.org/book/_single-page#aside-or_equals
      self.postal_code  ||= Rails.configuration.x.defaults.user_postal_code
      self.city         ||= Rails.configuration.x.defaults.user_city
      self.country      ||= Rails.configuration.x.defaults.user_country
    end

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
