module DepotCoordinatorsHelper

  # NOTE: This is an alternative version of the display_html method below.
  #       Leaving it here outcommented for reference of ways of achieving the
  #       same thing (without the form variant).
  # def display_html(coordinator)
  #   html = '<div class="depot-coordinator-info">'
  #   html << '<span class="full-name">'
  #   html << "#{coordinator.user.full_name}"
  #   html << '</span>'
  #   if coordinator.publish_tel_mobile
  #     tel         = coordinator.user.tel_mobile
  #     tel_display = coordinator.user.tel_mobile_formatted_national
  #     html << " #{icon_tel_to tel, tel_display}"
  #   end
  #   if coordinator.publish_email
  #     html << " #{icon_mail_to coordinator.user.email}"
  #   end
  #   html << '</div>'
  #   html.html_safe
  # end


  def publish_info_checkbox(coordinator, form, info)
    return unless form
    content_tag(:span, class: 'publish-checkbox') do
      form.field_for "coordinator_flags[#{coordinator.id}][publish_#{info}]",
        as_type: :boolean,
        value:   coordinator.send("publish_#{info}"),
        label:   t('.should_info_be_published')
     end
  end

  # Usually we define this kind of view logic directly as a '.html.erb'
  # partial file (see e.g. app/views/job_signups/_job_signup.html.erb).
  # For reference, we do the same here with a helper method instead.
  # However, it's still more clear to do this as a '.html.erb' partial
  # file.
  def display_depot_coordinator_html(coordinator, form: nil)
    css_class = 'full-name'
    css_class << ' canceled' if coordinator.canceled?
    content_tag :span, class: 'depot-coordinator-info' do
      if current_user_admin? && !form
        concat link_to(coordinator.user.full_name,
                       coordinator.user,
                       class: css_class)
      else
        concat content_tag(:span,
                           coordinator.user.full_name,
                           class: css_class)
      end
      if coordinator.not_canceled?
        if coordinator.publish_tel_mobile ||
          (action_name != "depot_lists") && (current_user_admin? || form)
          if tel        = coordinator.user.tel_mobile
            tel_display = coordinator.user.tel_mobile_formatted_national
            concat icon_tel_to(tel, tel_display,
                   published: coordinator.publish_tel_mobile )
            concat publish_info_checkbox(coordinator, form, :tel_mobile)
          else
            concat content_tag(:span, t('.no_mobile_phone_available'),
                               class: 'no-mobile-phone-available')
          end
        end
        if coordinator.publish_email ||
          (action_name != "depot_lists") && (current_user_admin? || form)
          concat icon_mail_to(coordinator.user.email,
                      published: coordinator.publish_email )
          concat publish_info_checkbox(coordinator, form, :email)
        end
      end
      if current_user_admin? && !form && (action_name != "depot_lists")
        if coordinator.not_canceled?
          concat link_to(
            t('.cancel_coordinator'),
            depot_cancel_coordinator_path(coordinator_id: coordinator.id),
            { class:  "btn btn-xs btn-danger cancel-button",
              method: :put,
              data: { confirm: t('.cancel_coordinator_confirmation_message') }})
        end
        concat(content_tag(:span, class: 'activation-date-info') do
          t( coordinator.canceled? ? '.active_from_to' :  '.active_since',
            from: coordinator.created_at.to_date.to_localized_s(:short),
            to:   coordinator.canceled? &&
                    coordinator.canceled_at.to_date.to_localized_s(:short)
            )
        end)
      end
    end
  end
end
