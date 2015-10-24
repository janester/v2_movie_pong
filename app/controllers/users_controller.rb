class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Success! Please log in"
      redirect_to(login_path)
    else
      flash[:validation_error] = @user.errors.messages
      redirect_to(new_user_path)
    end
  end
end
