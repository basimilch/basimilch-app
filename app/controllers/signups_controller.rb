class SignupsController < ApplicationController

  include SignupsHelper

  before_action :require_no_logged_in_user
  before_action :require_request_from_swiss_ip

  def new
    forget_successful_signup
    @user = User.new
  end

  def validation
    @user = User.new(user_params)
    if @user.validate
      validation_code = rand_validation_code
      remember_signup_for @user, validation_code.number
      send_email_validation_email @user, validation_code
    else
      render 'new'
    end
  end

  def create
    @user = User.new(session[:signup_info])
    unless already_successful_signup
      if entered_validation_code == session[:signup_validation_code]
        if @user.save
          send_signup_successful_email(@user)
          forget_signup
          remember_successful_signup
        else
          flash_now_t :danger, :unable_to_create_user
          render 'new'
        end
      else
        flash_now_t :danger, :wrong_email_validation_code
        render 'validation'
      end
    end
  end

private

  def remember_signup_for(user, validation_code)
    session[:signup_info] = user
    session[:signup_validation_code] = validation_code && validation_code.number
  end

  def forget_signup
    remember_signup_for nil, nil
    cookies.delete(:signup_validation_code)
    cookies.delete(:signup_info)
  end

  def remember_successful_signup
    session[:already_successful_signup] = true
  end

  def forget_successful_signup
    session[:already_successful_signup] = nil
    cookies.delete(:already_successful_signup)
  end

  def already_successful_signup
    session[:already_successful_signup]
  end

  def entered_validation_code
    params.require(:signup)[:email_validation_code].number
  end

  def send_email_validation_email(user, validation_code)
    UserMailer.email_validation(user, validation_code).deliver_now
  end

  def send_signup_successful_email(user)
    UserMailer.signup_successful(user).deliver_now
  end

end
