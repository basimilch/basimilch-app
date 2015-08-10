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
    @user = User.find(params[:id])
  end

  def new
  end
end
