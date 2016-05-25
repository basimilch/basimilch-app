class Subscription < ActiveRecord::Base

  include Cancelable
  include SubscriptionsHelper

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  def self.capture_week_number_env
    week_number_env = ENV['SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER'].not_blank
    case week_number_env
    when String
      logger.info "ENV['SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER'] =" +
                    " #{week_number_env.inspect}"
      # NOTE: :to_i returns 0 for nil
      next_week_number = week_number_env[/^\s*(\d+)\s*$/, 1].to_i
      if !(1..52).include? next_week_number
        logger.warn ("Invalid SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER." +
                      " Must be an integer between 1 and 52.").red
        nil
      elsif next_week_number < Date.current.cweek
        logger.warn ("SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER must be in" +
              " future. Current week number is #{Date.current.cweek}.").red
        nil
      else
        logger.info ("Valid SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER:" +
              " #{next_week_number}. Current week number is" +
              " #{Date.current.cweek}.").green
        logger.info ("Regular (i.e. non admin) users CAN update the" +
              " items of their subscription until week" +
              " #{next_week_number}.").yellow
        next_week_number
      end
    else
      logger.info ("SUBSCRIPTION_NEXT_UPDATE_WEEK_NUMBER ENV var not set" +
            " up. This is OK but means that regular (i.e. non admin) users" +
            " cannot update the items of their subscription.").yellow
      nil
    end
  end

  NEXT_UPDATE_WEEK_NUMBER = capture_week_number_env
  logger.debug "Subscription::NEXT_UPDATE_WEEK_NUMBER set to" +
                  " '#{NEXT_UPDATE_WEEK_NUMBER.inspect}'"

  UPDATE_DEADLINE_BEFORE_DELIVERY_DAY = 3.days

  belongs_to :depot
  has_many :subscriberships, -> { by_creation_date }
  has_many :users, -> { merge(Subscribership.not_canceled.by_creation_date) },
                   through: :subscriberships
  has_many :subscription_items
  has_many :current_items,  -> { merge SubscriptionItem.currently_valid },
                            foreign_key:  "subscription_id",
                            class_name:   "SubscriptionItem"
  # TODO: This is hard-coded to next Saturday to allow preloading of the
  #       relation. However it will have to be updated to be dependent on the
  #       delivery of the subscription.
  has_many :subscription_items_next_saturday,
            -> { merge(SubscriptionItem.valid_on_date(Date.next_wday(6)))},
                                  foreign_key:  "subscription_id",
                                  class_name:   "SubscriptionItem"

  default_scope -> { order(id: :asc) }
  scope :with_planned_items,
        -> { where(id: SubscriptionItem.with_planned_items_subscription_ids) }

  ALLOWED_NUMBER_OF_BASIC_UNITS = (1..4) # The upper limit is arbitrary
  ALLOWED_NUMBER_OF_SUPPLEMENT_UNITS = (0..3) # 4 supplements are like a basic

  MAX_NUMBER_OF_SUBSCRIBERS = 10 # arbitrary limit

  EQUIVALENT_IN_MILK_LITERS_BASIC_UNIT      = 8
  EQUIVALENT_IN_MILK_LITERS_SUPPLEMENT_UNIT = 2

  # The "flexible liters" are the liters that each subscription can distribute
  # as they prefer among the available product options.
  FLEXIBLE_LITERS_BASIC_UNIT      = EQUIVALENT_IN_MILK_LITERS_BASIC_UNIT / 2
  FLEXIBLE_LITERS_SUPPLEMENT_UNIT = EQUIVALENT_IN_MILK_LITERS_SUPPLEMENT_UNIT

  DEFAULT_SEPARATOR = ' - '

  validates :name, presence: false, length: { maximum: 100 }
  validates :depot_id, presence: true
  validate_id_for :depot
  validates :basic_units, presence: true,
              inclusion: { in: ALLOWED_NUMBER_OF_BASIC_UNITS }
  validates :supplement_units, presence: true,
              inclusion: { in: ALLOWED_NUMBER_OF_SUPPLEMENT_UNITS }
  validates :notes, presence: false, length: { maximum: 1000 }

  attr_accessor :subscriber_user_ids
  validate    :validate_subscribers,                  unless: :new_record?
  before_save :create_subscribers,                    unless: :new_record?
  before_save :capture_denormalized_subscribers_list, unless: :new_record?

  attr_accessor :item_ids_and_quantities
  validate    :validate_new_items,                    unless: :new_record?
  before_save :create_items,                          unless: :new_record?
  before_save :capture_denormalized_items_list,       unless: :new_record?

  attr_accessor :new_items_valid_from
  before_validation do
    self.new_items_valid_from = new_items_valid_from.try(:to_date)
  end

  # NOTE: The goal is that :to_s methods never do DB requests. If a :to_s with
  #       DB requests would be useful, implement a :to_s_detailed (see below).
  def to_s
    "Subscription #{id.inspect}:" +
      " #{basic_units} basic_units," +
      " #{supplement_units} supplement_units," +
      " #{self[:name].not_blank.inspect}"
  end

  def to_s_detailed
    to_s + ", #{users.count} user(s): #{user_last_names}"
  end

  def update_with_author(params, author)
    @author = author
    update(params)
  end

  def touch_with_author(author)
    @author = author
    save
    record_activity :update, self, owner: author
  end

  def next_modifiable_delivery_day
    depot.delivery_day_after(Date.current + UPDATE_DEADLINE_BEFORE_DELIVERY_DAY)
  end

  # Returns an array of the :valid_since dates of all items of this
  # subscription. The last one will be either the start date of the current
  # items, or the start date of the planned items, if any.
  def items_version_dates
    @items_version_dates ||= subscription_items.valid_since_dates
  end

  def upcomming_order_details
    # NOTE: Doing :pluck(:product_id, :quantity) instead of :map{} prevents
    #       rails from optimizing the DB request even using
    #       .includes(:current_items).
    Hash[subscription_items_next_saturday.map(&:product_and_quantity)].merge({
      subscription_count: 1,  # NOTE: This is an easy way to have a subscription
                              #       counter because it will end up added up.
      depot: depot,
      flexible_milk_liters: flexible_milk_liters
    })
  end

  def self.order_summary_by_depot
    Subscription.not_canceled
      .includes(:subscription_items_next_saturday)
      .includes(:depot)
      .map(&:upcomming_order_details)
      .group_by_key(:depot, pop_key: true)
      .update_vals(&:reduce_by_add)
  end

  def validity_of_current_items
    @validity_of_current_items ||= current_items
                                      .limit(1)
                                      .pluck(:valid_since, :valid_until)
                                      .first || []
  end

  def current_items_status
    if without_items?
      :empty
    elsif planned_items?
      :closed
    else
      :open
    end
  end

  # Returns true if there is a new set of items for this subscription to become
  # valid in the future. If that is the case, the currently valid items will
  # have an expiration date (i.e. :valid_until).
  def planned_items?
    validity_of_current_items.try(:second).present?
  end

  def planned_items_valid_since
    # NOTE: Equivalent to 'validity_of_current_items[1] + 1.day'
    items_version_dates.last if planned_items?
  end

  # Returns the planned items, which are the ones that are valid since the day
  # after the expiration date of the current ones. Confusing, I know. But it
  # makes sense when you think about it.
  def planned_items
    @planned_items ||= subscription_items.valid_on_date(
                                                       planned_items_valid_since
                                                     )
  end

  def planned_items_author_and_date
    return [nil, nil] unless planned_items?
    last_planned_items_activity = activities.order(id: :desc).find_by(
                                key: 'subscription.planned_items_list_modified'
                              )
    unless last_planned_items_activity.present?
      raise "last_planned_items_activity not found!"
    end
    [last_planned_items_activity.owner, last_planned_items_activity.created_at]
  end

  # Returns the number of liters that the subscription is equivalent to. This is
  # sometimes referred to as the "size" of the subscription.
  def equivalent_in_milk_liters
    basic_units * EQUIVALENT_IN_MILK_LITERS_BASIC_UNIT +
      supplement_units * EQUIVALENT_IN_MILK_LITERS_SUPPLEMENT_UNIT
  end

  # Returns the number of liters that the users of the subscription can decide
  # how to distribute among the available product options.
  def flexible_milk_liters
    basic_units * FLEXIBLE_LITERS_BASIC_UNIT +
      supplement_units * FLEXIBLE_LITERS_SUPPLEMENT_UNIT
  end

  def total_number_of_share_certificates
    users.map(&:number_of_valid_share_certificates).reduce(&:+) || 0
  end

  def total_number_of_jobs_done_this_year
    # NOTE: If a user did a job while being member of this subscription, but
    #       their subscribership was revoked since, the job will not be taken
    #       into account. This is strictly not correct, but should represent a
    #       little edge case not worth the complexity of being taken care of.
    users.map(&:count_of_jobs_done_this_year).reduce(&:+) || 0
  end

  def without_users?
    users.count.zero?
  end

  def without_items?
    current_items.count.zero?
  end

  # Returns a string with the last names of all members, useful e.g. as label.
  def user_last_names
    users.map(&:last_name).sort.join(DEFAULT_SEPARATOR).not_blank
  end

  # Returns the name of the subscription if set and a list of the user last
  # names otherwise.
  def name
    # SOURCE: http://stackoverflow.com/a/28362793
    # DOC: https://github.com/bbatsov/rails-style-guide#read-attribute
    self[:name].not_blank || user_last_names
  end

  def name=(name)
    self[:name] = (name == user_last_names) ? nil : name
  end

  def open_update_window?
    self.class.open_update_window? &&
      next_modifiable_delivery_day.cweek <= NEXT_UPDATE_WEEK_NUMBER
  end

  def self.open_update_window?
    NEXT_UPDATE_WEEK_NUMBER.present? &&
      Date.current.cweek <= NEXT_UPDATE_WEEK_NUMBER
  end

  def next_update_day_for_non_admins
    if open_update_window?
      Date.commercial Date.current.year,
                      NEXT_UPDATE_WEEK_NUMBER,
                      to_day_1_7(depot.delivery_day)
    elsif without_items?
      next_modifiable_delivery_day
    end
  end

  def can_be_updated_by?(user)
    # TODO: For the moment, users cannot not modify their subscription even if
    #       there are no items in it. This is because the modification date
    #       would be in the future, and we have to handle the display of items
    #       when there are only planned_items, but no current_items.
    #       See: test/models/subscription_test.rb
    # user.admin? || without_items? || open_update_window?
    user.admin? || open_update_window?
  end

  def current_items_liters
    current_items.reduce(0) { |acc, item| acc += item.liter_amount }
  end

  def valid_current_items?
    current_items_liters == flexible_milk_liters
  end

  private

    def user_can_subscribe?(user)
      !Subscribership.not_canceled.find_by(user_id: user.id)
    end

    def user_subscribed?(user)
      users.find_by(id: user.id).to_b
    end

    def cannot_subscribe?(user)
      !(user_subscribed?(user) || user_can_subscribe?(user))
    end

    def validate_subscribers
      subscriber_user_ids or return
      if (users.count + subscriber_user_ids.count) > MAX_NUMBER_OF_SUBSCRIBERS
        errors.add :base, I18n.t("errors.messages.max_number_of_subscribers",
                                 count: MAX_NUMBER_OF_SUBSCRIBERS)
      end
      subscriber_user_ids.each do |id|
        if ! user = User.find_by(id: id)
          logger.error "Unexpected user id: #{id.inspect}"
          errors.add :base, I18n.t("errors.messages.not_found.user", id: id)
        elsif cannot_subscribe? user
          logger.warn "User has already another subscription: #{id.inspect}"
          errors.add :base,
                     I18n.t("errors.messages.user_has_already_subscription",
                            user: user.full_name)
        end
      end
    end

    def create_subscribers
      subscriber_user_ids or return
      unless subscriber_user_ids.all? do |id|
          user = User.find_by(id: id)
          user and user_subscribed?(user) or subscriberships.create(user_id: id)
        end
        raise "Error creating subscribers! Ids: #{subscriber_user_ids}"
      end
    end

    # To be used as a 'before_save' callback.
    def capture_denormalized_subscribers_list
      self.denormalized_subscribers_list = users.map(&:to_s).sort
    end

    def validate_new_items
      item_ids_and_quantities or return
      total_size = item_ids_and_quantities.reduce(0) do |acc, (id, quantity)|
        # NOTE: There is no need to validate the id, because only ids of
        #       not_canceled ProductOptions are permitted in the
        #       SubscriptionController
        unless SubscriptionItem::ALLOWED_QUANTITIES.include? quantity.try(:to_i)
          logger.error "Unexpected product_option quantity: #{quantity.inspect}"
          errors.add :base,
                     I18n.t("errors.messages.product_option_unexpeted_quantity")
        end
        acc += ProductOption.find(id).equivalent_in_milk_liters * quantity.to_i
      end
      unless total_size == flexible_milk_liters
        errors.add :base, I18n.t(
          "errors.messages.wrong_total_quantity_of_new_subscription_items",
          actual_total:   total_size.to_s_significant,
          expected_total: flexible_milk_liters.to_s_significant)
      end
    end

    def close_current_items
      new_items_valid_from.present? or raise "missing new_items_valid_from"
      last_validity_day = new_items_valid_from - 1.day
      current_items.each { |item| item.close_at last_validity_day }
    end

    def current_items_valid_since_before_new_items?
      if current_items_valid_since_date = validity_of_current_items.first
        new_items_valid_from > current_items_valid_since_date
      end
    end

    def items_changed?
      without_items? or !item_ids_and_quantities.all? do |id, quantity|
        quantity.to_i.zero? || subscription_items.open.find_by(
          product_option_id: id,
          quantity: quantity,
          valid_since: new_items_valid_from
        ).to_b
      end
    end

    def record_items_change
      activity_key = if new_items_valid_from.future?
          :planned_items_list_modified
        else
          :current_items_list_modified
        end
      record_activity activity_key, self, owner: @author, data: {
        current_items:        current_items,
        planned_items:        planned_items,
        owner_is_subscriber:  user_subscribed?(@author),
        new_items_valid_from: new_items_valid_from
      }
    end

    def create_items
      unless @author.admin?
        # Regular users can only update at announced days.
        self.new_items_valid_from = next_update_day_for_non_admins
        # NOTE: If 'self.' is not added above, a new local variable named
        #       'new_items_valid_from' is instantiated even if the 'unless'
        #       branch is not executed, shadowing the corresponding accessor of
        #       the attribute 'new_items_valid_from', thus being always nil if
        #       the 'unless' branch is not executed, i.e. for admin users.
        # SOURCE: http://stackoverflow.com/a/4155041
      end
      return unless item_ids_and_quantities.present? && items_changed?
      close_current_items if current_items_valid_since_before_new_items?
      subscription_items.cancel_on_or_after_date new_items_valid_from,
                                                 author: @author
      logger.debug "Creating items #{item_ids_and_quantities.inspect}" +
                    " valid from #{new_items_valid_from.inspect}"
      item_ids_and_quantities.all? do |id, quantity|
        quantity.to_i.zero? || subscription_items.create(
          product_option_id: id,
          quantity: quantity,
          valid_since: new_items_valid_from
        ).valid?
      end or raise "Error creating items! Ids: #{item_ids_and_quantities}"
      record_items_change
    end

    # To be used as a 'before_save' callback.
    def capture_denormalized_items_list
      self.denormalized_items_list = current_items.map(&:to_s).sort
    end
end
