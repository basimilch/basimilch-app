module ActionFilterHelper

  # Before filters

  # Requires a logged in user.
  def require_logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t('.please_log_in')
      redirect_to login_url
    end
  end

  # Confirms an admin user.
  def admin_user
    raise_404 unless current_user.admin?
  end
end
