class User < ActiveRecord::Base

  # NOTE: A word of caution: 'after_initialize' means after the Ruby
  # initialize. Hence it is run every time a record is loaded from the
  # database and used to create a new model object in memory Source:
  # http://stackoverflow.com/a/4576026
  after_initialize :default_values

  # Inspired from
  #   https://www.railstutorial.org/book/_single-page#sec-format_validation

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_SWISS_POSTAL_CODE_REGEX = /\A\d{4}\z/ # The 'CH-' part is not expected.
  ONLY_SPACES       = /\A\s*\z/

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

  validates :postal_code, presence: true,
                          format: { with: VALID_SWISS_POSTAL_CODE_REGEX }
  validates :city,        presence: true
  validates :country,     presence: true

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

  private

    def default_values
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
end
