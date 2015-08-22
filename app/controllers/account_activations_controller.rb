class AccountActivationsController < ApplicationController

  before_action :require_logged_in_user,  only: [:create]
  before_action :get_user
  before_action :admin_user,              only: [:create]
  before_action :check_expiration,        only: [:edit, :update]

  def create
    @user.send_activation_email
    flash_t :success, :email_successfully_sent
    redirect_to user_path(@user)
  end

  def edit
    if @user &&
        !@user.activated? &&
        @user.authenticated?(:activation, params[:id])
      flash_now_t :info, :valid_activation_link
    else
      flash_t :danger, :invalid_activation_link
      redirect_to root_path
    end
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
    elsif @user.set_password(params)
      log_in @user
      @user.activate
      flash_t :success, :password_has_been_setup_and_account_activated
      redirect_to profile_path
    else
      render 'edit'
    end
  end

  private

    def get_user
      @user = User.find_by(email: params[:email])
      raise_404 unless @user
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.activation_expired?
        flash_t :danger, :activation_link_has_expired
        redirect_to root_path
      end
    end
end
