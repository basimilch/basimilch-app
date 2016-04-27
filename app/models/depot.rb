class Depot < ActiveRecord::Base

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common

  include Cancelable
  include HasPostalAddress

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  before_cancel :ensure_no_active_coordinators

  MAX_NUMBER_OF_COORDINATORS = 5
  DELIVERY_DAYS = (0..6).to_a.rotate # To make the 0, i.e. Sunday, appear last.
  DELIVERY_HOURS = (8..22)

  has_many :coordinators,
              # SOURCE: http://tomdallimore.com/blog/includes-vs-joins-in-rails-when-and-where/
              # SOURCE: http://blog.bigbinary.com/2013/07/01/preload-vs-eager-load-vs-joins-vs-includes.html
              # SOURCE: http://railscasts.com/episodes/181-include-vs-joins
              # DOC: http://api.rubyonrails.org/v4.2.5.2/classes/ActiveRecord/QueryMethods.html#method-i-includes
              -> { includes :user },
              foreign_key: "depot_id", class_name: "DepotCoordinator",
              dependent: :destroy

  scope :by_delivery_time, -> { order(delivery_day: :asc)
                                .order(delivery_time: :asc)
                                .order(id: :asc) }

  # NOTE: A word of caution: 'after_initialize' means after the Ruby
  #       initialize. Hence it is run every time a record is loaded from the
  #       database and used to create a new model object in memory Source:
  #       http://stackoverflow.com/a/4576026
  after_initialize :default_values_delivery_time

  validates :name,          presence: true, length: { maximum: 100 }
  validates :directions,    presence: true, length: { maximum: 1000 }
  validates :delivery_day,  presence: true, inclusion: { in: DELIVERY_DAYS }
  validates :delivery_time, presence: true, inclusion: { in: DELIVERY_HOURS }
  validates :opening_hours, presence: true, length: { maximum: 250 }

  VALID_COORDINATES_REGEX = /\d{1,3}\.\d{1,8}\s*,\s*\d{1,3}\.\d{1,8}/
  validates :exact_map_coordinates, allow_blank: true,
                                    format: { with: VALID_COORDINATES_REGEX }
  before_save :sanitize_exact_map_coordinates

  mount_uploader :picture, PictureUploader

  validate    :validate_coordinators
  before_save :update_coordinators, unless: :new_record?
  after_save :create_coordinators

  attr_accessor :coordinator_user_ids
  attr_accessor :coordinator_flags

  def to_s
    "Depot #{id.inspect}: #{name.inspect} - #{full_postal_address.inspect}"
  end

  def sanitize_exact_map_coordinates
    if exact_map_coordinates.present?
      self.exact_map_coordinates = exact_map_coordinates.sub(
          RegexpUtils::MULTIPLE_COMMA_SEPARATION, ','
        )
    end
  end

  def latitude
    if exact_map_coordinates.present?
      exact_map_coordinates.split(',')[0]
    else
      # SOURCE: http://stackoverflow.com/a/28362793
      # DOC: https://github.com/bbatsov/rails-style-guide#read-attribute
      self[:latitude]
    end
  end

  def longitude
    if exact_map_coordinates.present?
      exact_map_coordinates.split(',')[1]
    else
      # SOURCE: http://stackoverflow.com/a/28362793
      # DOC: https://github.com/bbatsov/rails-style-guide#read-attribute
      self[:longitude]
    end
  end

  def active_coordinators
    coordinators.not_canceled
  end

  # Returns the coordinator of the current depot with the given *user* id (i.e.
  # not coordinator id), or 'nil' otherwise.
  def active_coordinator(user_id)
    active_coordinators.find_by(user_id: user_id)
  end

  private

    def default_values_delivery_time
      self.delivery_day  ||= 6   # Saturday is the default delivery day
      self.delivery_time ||= 16  # The default delivery time is 16h
    end

    def validate_coordinators
      coordinator_user_ids or return
      unless coordinator_user_ids.all? { |id| User.find_by(id: id) }
        logger.error "Wrong coordinator ids: #{coordinator_user_ids.inspect}"
        errors.add :coordinators, I18n.t("errors.messages.wrong")
      end
    end

    def create_coordinators
      coordinator_user_ids or return
      unless coordinator_user_ids.all? do |id|
          active_coordinator(id) or coordinators.create(user_id: id)
        end
        raise "Error creating coordinators! Ids: #{coordinator_user_ids}"
      end
    end

    def update_coordinators
      coordinator_flags or return
      unless coordinator_flags.all? do |coordinator_id, flags|
          if coordinator = active_coordinators.find_by(id: coordinator_id)
            coordinator.publish_tel_mobile  = flags['publish_tel_mobile'].to_b
            coordinator.publish_email       = flags['publish_email'].to_b
            coordinator.save
          end
        end
        raise "Error updating coordinators! Flags: #{coordinator_flags}"
      end
    end

    def ensure_no_active_coordinators
      active_coordinators.empty?
    end
end
