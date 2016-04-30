module CancelableHelper

  def cancelation_flash(model)
    model.canceled? or return false
    prefix = model.class.to_s.underscore
    cancellation_author = User.find_by(id: model.canceled_by_id)
    t_key = if !current_user_admin?
              ".#{prefix}_canceled"
            elsif current_user? cancellation_author
              ".#{prefix}_canceled_by_current_user"
            elsif cancellation_author
              ".#{prefix}_canceled_by_user"
            else
              ".#{prefix}_canceled_by_unknown"
            end
    flash_now_t :warning,
        t(t_key,
          canceled_at:      model.canceled_at.to_localized_s,
          canceled_by:      cancellation_author.try(:full_name),
          canceled_by_url:  cancellation_author &&
                              user_path(cancellation_author))
    return true
  end
end
