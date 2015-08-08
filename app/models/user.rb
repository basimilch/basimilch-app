class User < ActiveRecord::Base

  # Inspired from
  #   https://www.railstutorial.org/book/_single-page#sec-format_validation

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email,       presence: true,
                          length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }
  before_save { self.email = email.downcase }

  validates :password,    presence: true,
                          length: { in: 8..100 }

  validates :first_name,  presence: true,
                          length: { maximum: 40 }

  validates :last_name,   presence: true,
                          length: { maximum: 40 }

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

  after_initialize { self.country = I18n.t :switzerland }

  has_secure_password

  def formatted_tel(tel_type)
    if valid?
      raw_tel = send "tel_#{tel_type}" || ""
      # Source:
      #   https://github.com/floere/phony/blob/master/qed/format.md#options
      raw_tel.phony_formatted(:normalize => 'CH',
                              :format => :international, # => "+41 76 111 11 11"
                              # :format => :national,    # => "076 111 11 11"
                              :spaces => ' ')
    end
  end

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
end
