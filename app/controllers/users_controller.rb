class UsersController < ApplicationController

  def index
    if filter = params[:filter]
      @users = User.find_by(filter) || []
    else
      @users = User.all
    end
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=" +
                            "\"#{Time.now.to_s(:number)}_" +
                            "#{I18n.t("users.index.csv_file_basemane")}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    unless @user = User.find_by_id(params[:id])
      # TODO: Redirect to 404 instead
      flash[:danger] = t('users.show.flash.user_not_found', id: params[:id])
      redirect_to users_path
    end
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
      flash[:success] = t('users.show.flash.user_successfully_created',
                        id: @user.id, full_name: @user.full_name)
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    unless @user = User.find_by_id(params[:id])
      # TODO: Redirect to 404 instead
      flash[:danger] = t('users.show.flash.user_not_found', id: params[:id])
      redirect_to users_path
    end
  end

  def update
    # TODO:
    # flash[:success] = t('users.show.flash.user_updated',
    #                      id: @user.id, full_name: @user.full_name)
    flash[:danger] = "UPDATE NOT YET IMPLEMENTED"
    redirect_to User.find_by_id(params[:id]) || users_path
  end

  private

    def user_params
      # Pattern 'strong parameters' to secure form input.
      # Source:
      #   https://www.railstutorial.org/book/_single-page#sec-strong_parameters
      params.require(:user).permit(:first_name,
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
                                   :notes)
    end
end
