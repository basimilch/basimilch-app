module SessionsHelper

  # Inspired from https://www.railstutorial.org/book/_single-page#sec-logging_in

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    user.record_last_login from: request.try(:remote_ip_and_address)
  end

  # Remembers a user in a persistent session.
  def remember(user)
    logger.debug "Remember user '#{user && user.email}'"
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session.
  def forget(user)
    logger.debug "Forget user '#{user && user.email}'"
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Returns the current logged-in user (if any), nil otherwise.
  def current_user
    if @current_user
      @current_user
    elsif (user_id = session[:user_id])
      @current_user = User.find_by(id: user_id)
      if @current_user
        @current_user.seen
        @current_user
      else
        # The user id in the cookie does not exist in the DB anymore.
        # This might happen e.g. after re-seeding a dev DB.
        session.delete(:user_id)
        nil
      end
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns true if the current user is admin, false otherwise.
  def current_user_admin?
    current_user && current_user.admin?
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
