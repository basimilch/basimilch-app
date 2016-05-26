module DepotsHelper

  def current_user_depot?
    'depot' == action_name
  end

  def delivery_time_message(depot)
    t '.delivery_time_message',
      day: localized_weekday_name(depot.delivery_day),
      time: depot.delivery_time
  end

  def options_for_depot_delivery_days(depot, selected_date: nil,
                                             after_date: nil)
    grouped_options_for_select(
      depot.delivery_days_of_current_year.select do |d|
        after_date.nil? || d > after_date.to_date
      end.map do |d|
        [d.to_localized_s(:long), d]
      end.group_by do |option|
        option[1].to_localized_s :long_month_and_year
      end,
      selected_date.try(:to_date)
    )
  end

  # Returns a string to be used as the HTML id of a depot element and used in
  # a URL as anchor (aka hash) to scroll to the element with this HTML id.
  def depot_anchor(depot)
    "depot-#{depot.id}"
  end
end
