class UsersController < ApplicationController
  def show
  end

  def new
    @user = User.new
  end

  def create
    User.create(params[:user])
    redirect_to(login_path)
  end
end