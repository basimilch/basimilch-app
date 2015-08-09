class UsersController < ApplicationController

  def index
    if filter = params[:filter]
      @users = User.find_by(filter) || []
    else
      @users = User.all
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
  end
end
