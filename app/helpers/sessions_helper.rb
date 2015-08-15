module SessionsHelper

  # Inspired from https://www.railstutorial.org/book/_single-page#sec-logging_in

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any), nil otherwise.
  def current_user
    # NOTE: To learn about the or-equals (i.e. '||=') form, see
    #       https://www.railstutorial.org/book/_single-page#aside-or_equals
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
