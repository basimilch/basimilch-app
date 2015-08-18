class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if not user
      # No user found
      flash.now[:danger]  = 'USER NOT FOUND'
    elsif user.password_digest.blank?
      # User doesn't have password, i.e. it's not yet active
      flash.now[:danger]  = 'USER INACTIVE'
    elsif user.authenticate(params[:session][:password])
      log_in user
      # NOTE: By default we remember the user. Add a checkbox on the login form
      #       with name 'remember_me' to offer the choice to the user.
      params[:session][:remember_me] == '0' ? forget(user) : remember(user)
      redirect_back_or user
      return
    else
      # Active user found, but wrong password
      flash.now[:danger]  = 'INVALID EMAIL/PASSWORD COMBINATION'
    end
    render 'new'
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end
end
