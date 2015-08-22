class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.send_password_reset_email
      flash_t :info, :email_sent_with_password_reset_instructions
      redirect_to login_url
    else
      flash_now_t :danger, :email_address_not_found
      render 'new'
    end
  end

  def edit
    flash_t :info, :valid_password_reset_link
  end

  def update
    if params[:user][:password].empty?
      # NOTE: The 'present' validation has been disabled to allow creating users
      #       without password. Therefore we have to manually add the error
      #       message here.
      # Source: https://www.railstutorial.org/book/_single-page
      #                                       #code-password_reset_update_action
      @user.errors.add(:password, t('errors.messages.empty'))
      render 'edit'
    elsif @user.reset_password(params)
      log_in @user
      flash_t :success, :password_has_been_reset
      redirect_to profile_path
    else
      render 'edit'
    end
  end

  private

    # Before filters

    def get_user
      @user = User.find_by(email: params[:email].downcase)
    end

    # Confirms a valid user.
    def valid_user
      unless @user &&
             @user.activated? &&
             @user.authenticated?(:password_reset, params[:id])
        raise_404
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = I18n.('.password_reset_has_expired')
        redirect_to new_password_reset_url
      end
    end
end
