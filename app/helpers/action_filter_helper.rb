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



  DEFAULT_URL_DOMAIN_FOR_REFERER_FILTER =
    ENV["DEFAULT_URL_DOMAIN_FOR_REFERER_FILTER"]

  DEFAULT_REDIRECT_URL_FOR_REFERER_FILTER =
    ENV["DEFAULT_REDIRECT_URL_FOR_REFERER_FILTER"]

  BYPASS_REFERER_FILTER =
    ENV["BYPASS_REFERER_FILTER"].to_b
  # To pass specific domains as arguments, do as follow:
  #
  # before_action -> { require_referer_domain "basimil.ch",
  #                                           redirect_to_url: "/" },
  #               only: [:new]
  #
  # SOURCE: http://stackoverflow.com/a/20561223
  # SOURCE: http://stackoverflow.com/a/3104799
  def require_referer_domain(domain = DEFAULT_URL_DOMAIN_FOR_REFERER_FILTER,
                       redirect_to_url: DEFAULT_REDIRECT_URL_FOR_REFERER_FILTER)
    return if BYPASS_REFERER_FILTER or !Rails.env.production?
    raise ArgumentError, "domain must be provided" if domain.blank?
    referer_url = request.env['HTTP_REFERER']
    referer_regexp = Regexp.new("^https?://([^/]+\\.)?#{domain}(?:/.*)?")
    if referer_url.blank? || !referer_url.match(referer_regexp)
      logger.warn "HTTP_REFERER '#{referer_url.inspect}' does not match" +
                  " domain '#{domain}'" +
                  " (Request from IP #{request.remote_ip.inspect}.)"
      unless redirect_to_url.blank?
        redirect_to redirect_to_url
      else
        raise_404
      end
    end
  end

  BYPASS_SWISS_IP_FILTER = ENV["BYPASS_SWISS_IP_FILTER"].to_b

  def require_request_from_swiss_ip
    return if BYPASS_SWISS_IP_FILTER or !Rails.env.production?
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
