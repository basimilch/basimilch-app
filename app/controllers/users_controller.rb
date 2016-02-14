class UsersController < ApplicationController

  # All actions require a logged in user.
  before_action :require_logged_in_user
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user,   only: [:new, :show, :index, :destroy, :activate]

  def index
    if filter = params[:filter]
      # NOTE: .find_by(...) is like .where(...).first
      # Source: http://stackoverflow.com/a/22833860
      @users = User.where(filter.permit(PERMITTED_ATTRIBUTES))
    elsif @view = params[:view]
      unless @users = User.try(@view)
        raise_404
      end
    else
      @users = User.by_name
    end
    respond_to do |format|
      format.html
      format.json do
        # Source: http://www.daveperrett.com/articles/2010/10/03/
        #                       excluding-fields-from-rails-json-and-xml-output/
        render json: @users, except: :password_digest
      end
      format.xml do
        render xml: @users, except: :password_digest
      end
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=" +
                            "\"#{Time.now.to_s(:number)}_" +
                            "#{I18n.t("users.index.csv_file_basemane")}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    @user = User.find(params[:id])
    title_label :admin, type: :warning if @user.admin?
    if !@user.activated?
      title_label :inactive
      if @user.activation_sent_at && @user.activation_sent_at < 5.seconds.ago
        flash.now[:warning] = t('.activation_already_sent_at',
                            sent_at: I18n.l(@user.activation_sent_at))
      end
    else
      title_label :active, type: :success
    end
  end

  def profile
    if current_user.admin?
      title_label :admin, type: :warning
      title_label :active, type: :success
    end
    @user = User.find(current_user.id)
    render 'show'
  end

  def profile_edit
    @user = User.find(current_user.id)
    render 'edit'
  end

  def profile_update
    @user = User.find(current_user.id)
    if @user.update_attributes(user_params)
      record_activity :update, @user
      flash_t :success, :update_ok
      redirect_to profile_path
    else
      render 'edit'
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.reload
      record_activity :create, @user
      flash[:success] = t('.flash.user_successfully_created',
                        id: @user.id, full_name: @user.full_name)
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      record_activity :update, @user
      flash[:success] = t('.flash.user_updated')
      redirect_to @user
    else
      render 'edit'
    end
  end

  def activate
    @user = User.find(params[:id])
    @user.send_activation_email
    record_activity :send_account_activation, @user
    flash_t :success,
            t(".account_activated_and_email_successfully_sent",
              email: @user.email)
    redirect_to @user
  end

  private

    # Before filters

    # Requires the correct user.
    def correct_user
      @user = User.find(params[:id])
      # TODO: Consider returning a 403 or 404 instead of redirecting to root.
      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
    end
end
