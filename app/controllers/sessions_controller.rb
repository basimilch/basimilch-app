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
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
      return
    else
      # Active user found, but wrong password
      flash.now[:danger]  = 'INVALID EMAIL/PASSWORD COMBINATION'
    end
    render 'new'
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
