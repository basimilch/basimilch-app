module SubscriptionsHelper

  def current_user_subscription?
    ['subscription', 'subscription_edit'].include? action_name
  end

  def localized_subscription_size(subscription)
    size = t '.units.basic', count: subscription.basic_units
    supplement_units = subscription.supplement_units
    if supplement_units.pos?
      size << ' ' + t('.units.supplement',
                      count: subscription.supplement_units)
    end
    return size
  end

  def localized_subscription_size_equivalence(subscription,
                                              liters: nil,
                                              flexible_liters: nil)
    t '.equivalent_in_milk_liters_msg',
      liters: liters || subscription.equivalent_in_milk_liters.to_s_significant,
      flexible_liters: flexible_liters ||
                          subscription.flexible_milk_liters.to_s_significant
  end

  def localized_subscription_delivery_day(subscription)
    localized_weekday_name(subscription.depot.delivery_day)
  end

  def localized_validity_of_current_items(subscription)
    valid_since, valid_until = subscription.validity_of_current_items
    {
      valid_since_tag: localized_date_tag(valid_since, :short),
      valid_until_tag: localized_date_tag(valid_until, :short),
      planned_items_valid_since_tag:
        localized_date_tag(subscription.planned_items_valid_since, :short),
      non_admin_planned_items_valid_since_tag:
        localized_date_tag(subscription.next_update_day_for_non_admins, :short)
    }
  end

  def localized_modification_details(subscription)
    author, date = subscription.planned_items_author_and_date
    {
      by_author:  if current_user?(author)
                    t('.by.you')
                  else
                    t('.by.user_html', user: user_label_html(author))
                  end,
      date_tag:   localized_time_tag(date, :short_only_date)
    }
  end

  # Returns the option tags to select the depots of a subscription.
  def options_for_subscription_depot(subscription)
    options_for_select(
      Depot.not_canceled.map do |depot|
        [depot.to_s, depot.id]
      end,
      subscription.depot_id
      )
  end

  # Returns the option tags to select the number of basic subscription units.
  def options_for_subscription_basic_units(subscription)
    options_for_select(
      Subscription::ALLOWED_NUMBER_OF_BASIC_UNITS.map do |n|
        [t('.units.basic', count: n), n]
      end,
      subscription.basic_units
      )
  end

  # Returns the option tags to select the number of supplement subscription
  # units.
  def options_for_subscription_supplement_units(subscription)
    options_for_select(
      Subscription::ALLOWED_NUMBER_OF_SUPPLEMENT_UNITS.map do |n|
        [t('.units.supplement', count: n), n]
      end,
      subscription.supplement_units
      )
  end

  def options_for_subscription_delivery_days(subscription)
    depot = subscription.depot
    options = if subscription.without_items?
     {}
    elsif subscription.open_update_window?
      { selected_date: subscription.next_update_day_for_non_admins }
    elsif subscription.planned_items?
      { selected_date: subscription.planned_items_valid_since }
    else
      { selected_date: subscription.next_modifiable_delivery_day }
    end
    options_for_depot_delivery_days depot, options
  end

  def subscription_current_quantity(subscription, product_option)
    if subscription.item_ids_and_quantities.present?
      subscription.item_ids_and_quantities[product_option.id.to_s]
    elsif subscription.planned_items?
      subscription.planned_items.quantity(product_option)
    else
      subscription.current_items.quantity(product_option)
    end.to_i
  end

  # Sunday is normally 0 but in Date.commercial is 7.
  def to_day_1_7(day_0_6)
    [7,1,2,3,4,5,6,7][day_0_6.to_i] if [0,1,2,3,4,5,6,7].include? day_0_6
  end
end
