class SignupsController < ApplicationController

  include SignupsHelper

  before_action :require_no_logged_in_user
  before_action :require_referer_domain, only: [:new]
  before_action :require_request_from_swiss_ip, only: [:new]

  def new
    forget_successful_signup
    @user = User.new(query_params)
  end

  def validation
    @user = User.new(user_params)
    logger.debug "Validating signup information: #{@user.inspect}"
    if @user.validate
      logger.debug " => validation ok. Sending validation email."
      validation_code = rand_validation_code
      remember_signup_for @user, validation_code.number
      send_email_validation_email @user, validation_code
    else
      logger.debug " => validation failed. Asking to fix the information."
      render 'new'
    end
  end

  def create
    @user = User.new(session[:signup_info])
    unless already_successful_signup
      if entered_validation_code == session[:signup_validation_code]
        if @user.save
          logger.info "New successful signup for user id #{@user.id}" +
                      " (#{@user.email})"
          logger.debug "#{@user.inspect}"
          record_activity :new_user_signup, @user
          create_wanted_share_certificates @user
          send_signup_successful_email(@user)
          send_new_signup_notification(@user)
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
      session[:signup_info] = user.try(:attributes, include_virtual: true)
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
      record_activity :send_signup_successful_notification, user
    end

    def send_new_signup_notification(user)
      location_info = request.remote_ip_and_address
      UserMailer.new_signup_notification(user, location_info).deliver_now
      record_activity :send_new_signup_notification, user, data: {
        signup_remote_ip: location_info
      }
    end

  def create_wanted_share_certificates(user)
    user.wanted_number_of_share_certificates.to_i.times do
      new_share_certificate = user.share_certificates.build
      if new_share_certificate.save
        record_activity :create, new_share_certificate
      else
        raise "Not able to save: #{new_share_certificate.inspect}"
      end
    end
  end
end
