module DepotsHelper

  def delivery_time_message(depot)
    t '.delivery_time_message',
      day: localized_weekday_name(depot.delivery_day),
      time: depot.delivery_time
  end
end
