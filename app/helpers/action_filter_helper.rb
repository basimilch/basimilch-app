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

  # Requires that no user is logged in, and redirects to /profile if so.
  def require_no_logged_in_user
    if logged_in?
      redirect_to profile_path
    end
  end

  # Confirms an admin user.
  def admin_user
    raise_404 unless current_user.admin?
  end
end
