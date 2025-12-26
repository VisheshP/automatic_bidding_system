class SessionsController < ApplicationController
  def new
    if user_logged_in?
      redirect_to items_path
    end
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      login(@user)
      redirect_to items_path
    else
      flash[:alert] = "Invalid email or password"
      redirect_to login_path
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end