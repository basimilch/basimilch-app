class User < ActiveRecord::Base

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_SWISS_POSTAL_CODE_REGEX = /\A\d{4}\z/ # The 'CH-' part is not expected.
  ONLY_SPACES       = /\A\s*\z/

  ACTIVATION_TOKEN_VALIDITY = 2.weeks
  PASSWORD_RESET_TOKEN_VALIDITY = 30.minutes

  attr_accessor :remember_token, :activation_token, :password_reset_token

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
  before_save { self.email = email.downcase }

  has_secure_password validations: false
  validates :password,    presence: false, # Users will create a password after
                                           # account validation.
                          allow_nil: true,
                          allow_blank: false,
                          confirmation: true,
                          format: { without: ONLY_SPACES },
                          length: { in: 8..72 } # Max restored from:
                                                # https://github.com/rails/rails
                                                # /blob/v4.2.3/activemodel/lib/
                                                # active_model/secure_
                                                # password.rb#L21

  validates :first_name,  presence: true,
                          length: { maximum: 40 }

  validates :last_name,   presence: true,
                          length: { maximum: 40 }

  validates :postal_address,  presence: true
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
    update_attribute(:remember_digest, User.digest(remember_token))
    update_attribute(:remembered_since, Time.current)
  end

  # Returns true if the given token matches the digest.
  # Source: https://www.railstutorial.org/book/_single-page
  #                                            #code-generalized_authenticated_p
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_token, nil)
    update_attribute(:remembered_since, nil)
  end

  # Returns the point in time until which the activation token is valid.
  def activation_token_valid_until
    activation_sent_at &&
      activation_sent_at + ACTIVATION_TOKEN_VALIDITY
  end

  # Sends activation email.
  def send_activation_email
    create_activation_digest
    update_attribute(:activation_sent_at, Time.current)
    UserMailer.account_activation(self).deliver_now
  end

  # Activates an account.
  def activate
    update_attribute(:activated,          true)
    update_attribute(:activated_at,       Time.current)
    update_attribute(:activation_digest,  nil)
  end

  def set_password(params_arg)
    update_attributes(params_arg
                        .require(:user)
                        .permit(:password, :password_confirmation))
  end


  # Returns true if a account activation link has expired.
  def activation_expired?
    activation_token_valid_until < Time.current
  end

  # Returns the point in time until which the activation token is valid.
  def password_reset_token_valid_until
    password_reset_sent_at &&
      password_reset_sent_at + PASSWORD_RESET_TOKEN_VALIDITY
  end

  # Sends password reset email.
  def send_password_reset_email
    create_password_reset_digest
    update_attribute(:password_reset_sent_at, Time.current)
    UserMailer.password_reset(self).deliver_now
  end

  def reset_password(params_args)
    updated = set_password(params_args)
    if updated
      update_attribute(:password_reset_at,      Time.current)
      update_attribute(:password_reset_digest,  nil)
    end
    updated
  end

  # Returns true if a account activation link has expired.
  def password_reset_expired?
    password_reset_token_valid_until < Time.current
  end

  # Class methods

  # Returns the hash digest of the given string.
  # Source: https://www.railstutorial.org/book/_single-page#code-digest_method
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  # Source: https://www.railstutorial.org/book/_single-page#code-token_method
  def User.new_token
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

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      update_attribute(:activation_digest, User.digest(activation_token))
    end

    # Sets the password reset attributes.
    def create_password_reset_digest
      self.password_reset_token = User.new_token
      update_attribute(:password_reset_digest, User.digest(password_reset_token))
    end
end
