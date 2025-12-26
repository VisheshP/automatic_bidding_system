class UsersController < ApplicationController
  before_action :authenticate, except: %i[new create]
  before_action :set_user, only: %i[ show edit update destroy ]
  

 
  def show
    @items = @user.bids
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      login(@user)
      flash[:notice] = "Welcome, #{@user.full_name}!"
      redirect_to items_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Account updated!"
      redirect_to edit_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = "Account deleted!"
    redirect_to users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :role, :password, :password_confirmation)
  end
end