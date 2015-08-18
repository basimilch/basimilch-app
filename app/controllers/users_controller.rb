class UsersController < ApplicationController

  include ApplicationHelper

  # All actions require a logged in user.
  before_action :require_logged_in_user
  before_action :correct_user, only: [:view, :edit, :update]
  before_action :admin_user,   only: [:new, :index, :destroy]

  PERMITTED_ATTRIBUTES = [:first_name,
                          :last_name,
                          :email,
                          :postal_address,
                          :postal_code,
                          :city,
                          :country,
                          :tel_mobile,
                          :tel_mobile_formatted,
                          :tel_home,
                          :tel_home_formatted,
                          :tel_office,
                          :tel_office_formatted,
                          :admin,
                          :notes]

  def index
    if filter = params[:filter]
      # NOTE: .find_by(...) is like .where(...).first
      # Source: http://stackoverflow.com/a/22833860
      @users = User.where(filter.permit(PERMITTED_ATTRIBUTES))
    else
      @users = User.all
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
  end

  def profile
    @user = current_user
    render 'show'
  end

  def profile_edit
    @user = current_user
    render 'edit'
  end

  def new
    @user = User.new
    @form_field_options = {
      country:  { readonly: true },
      admin:    { field_type: 'check_box' },
      notes:    { field_type: 'text_area' }
    }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.reload
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
      flash[:success] = t('.flash.user_updated')
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      # Pattern 'strong parameters' to secure form input.
      # Source:
      #   https://www.railstutorial.org/book/_single-page#sec-strong_parameters
      params.require(:user).permit(PERMITTED_ATTRIBUTES)
    end

    # Before filters

    # Requires a logged in user.
    def require_logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = t('.please_log_in')
        redirect_to login_url
      end
    end

    # Requires the correct user.
    def correct_user
      @user = User.find(params[:id])
      # TODO: Consider returning a 403 or 404 instead of redirecting to root.
      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
