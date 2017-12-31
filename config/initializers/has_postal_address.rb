# Adds the ability to have and validate a postal address.
module HasPostalAddress

  VALID_SWISS_POSTAL_CODE_REGEX = /\A\d{4}\z/ # The 'CH-' part is not expected.

  # DOC: http://api.rubyonrails.org/v5.1.4/classes/ActiveSupport
  #                                       /Concern.html#method-i-append_features
  extend ActiveSupport::Concern

  # TODO: Consider refactoring this check together with the one in Cancelable.
  # SOURCE: http://stackoverflow.com/a/1328093
  def self.included_in?(klass)
    klass.class == Class or raise "Parameter must be a class."
    klass.included_modules.include? self
  end

  included do

    # TODO: Consider refactoring this check together with the one in Cancelable.
    unless {postal_address:             :string,
            postal_address_supplement:  :string,
            postal_code:                :string,
            city:                       :string,
            country:                    :string,
            # :latitude and :longitude fields are required for the geocoder gem.
            # DOC: https://github.com/alexreisner/geocoder/tree/v1.3.7#activerecord
            latitude:                   :float,
            longitude:                  :float}.all? do |col, typ|
              columns_hash[col.to_s].try(:type) == typ
            end
      # DOC: http://ruby-doc.org/core-2.2.1/doc/syntax/literals_rdoc.html#label-Here+Documents
      raise MissingMigrationException, <<-ERROR_MSG.red
Model #{self} is missing the columns required by Cancelable.

# Add following migration:

cat << EOF > #{File.expand_path('../../..', __FILE__)}/db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_add_cancelable_columns_to_#{table_name}.rb
class AddPostalAddressColumnsTo#{table_name.titleize} < ActiveRecord::Migration
  def change
    add_column      :#{table_name}, :postal_address,            :string
    add_column      :#{table_name}, :postal_address_supplement, :string
    add_column      :#{table_name}, :postal_code,               :string
    add_column      :#{table_name}, :city,                      :string
    add_column      :#{table_name}, :country,                   :string
    add_column      :#{table_name}, :latitude,                  :float
    add_column      :#{table_name}, :longitude,                 :float
  end
end
EOF

# and then migrate the DB:

bundle exec rake db:migrate

ERROR_MSG
    end

    validates :postal_address,  presence: true
    validates :postal_address_supplement, length: { maximum: 50 }
    validates :postal_code,     presence: true,
                                format: { with: VALID_SWISS_POSTAL_CODE_REGEX }
    validates :city,            presence: true
    validates :country,         presence: true

    validate :correct_full_postal_address

    geocoded_by :full_postal_address

    # NOTE: A word of caution: 'after_initialize' means after the Ruby
    #       initialize. Hence it is run every time a record is loaded from the
    #       database and used to create a new model object in memory Source:
    #       http://stackoverflow.com/a/4576026
    after_initialize :default_values_for_postal_address

  end

  def full_postal_address(separator: ', ')
    [postal_address, postal_code, city, country].compact.join(separator)
  end

  def city_postal_address
    "#{postal_address}, #{postal_code} #{city}"
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

  private

    def default_values_for_postal_address
      # NOTE: To learn about the or-equals (i.e. '||=') form, see
      #       https://www.railstutorial.org/book/_single-page#aside-or_equals
      self.postal_code  ||= Rails.configuration.x.defaults.user_postal_code
      self.city         ||= Rails.configuration.x.defaults.user_city
      self.country      ||= Rails.configuration.x.defaults.user_country
    end

end

# TODO: Consider refactoring this class together with the one in Cancelable.
class MissingMigrationException < Exception
end
