module DepotsHelper

  def current_user_depot?
    'depot' == action_name
  end

  def delivery_time_message(depot)
    t '.delivery_time_message',
      day: localized_weekday_name(depot.delivery_day),
      time: depot.delivery_time
  end

  def delivered_at_depot_info(depot)
    if depot.present?
      content_tag :div, class:'depot-info' do
        concat t('.depot_label') + ' '
        concat (
          if action_name[/edit$/]
            content_tag :span do
              concat content_tag(:strong, depot.name)
              concat content_tag(:span, " - #{depot.city_postal_address}")
            end
          else
            link_to (current_user_admin? ? depot : current_user_depot_path) do
              concat content_tag(:strong, depot.name)
              concat content_tag(:span, " - #{depot.city_postal_address}")
            end
          end
        )
      end
    end
  end

  # Returns a string to be used as the HTML id of a depot element and used in
  # a URL as anchor (aka hash) to scroll to the element with this HTML id.
  def depot_anchor(depot)
    "depot-#{depot.id}"
  end
end
