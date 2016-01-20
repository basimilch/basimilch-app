module ActionFilterHelper

  # Before filters

  # Requires a logged in user.
  def require_logged_in_user
    unless logged_in?
      store_location
      flash_t :danger, :please_log_in, global: true
      redirect_to login_url
    end
  end

  # Requires that no user is logged in, and redirects to /jobs if so.
  def require_no_logged_in_user
    if logged_in?
      redirect_to jobs_path
    end
  end

  # Confirms an admin user.
  def admin_user
    raise_404 unless current_user.admin?
  end

  def require_request_from_swiss_ip
    return unless Rails.env.production?
    result = Geocoder.search(request.remote_ip).first
    unless result && result.country_code == "CH"
      logger.warn "Unauthorised signup request from IP " +
                   "#{request.remote_ip.inspect}: #{result.inspect}"
      # TODO: Render a page explaining that the signup can only be done from CH.
      raise_404
    end
  end

  def user_exists(id: nil)
    unless User.find_by(id: id)
      errors.add(:user_id, I18n.t("errors.messages.user_not_found",
                                  id: id))
    end
  end
end
