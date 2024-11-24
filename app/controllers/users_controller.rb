class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcom to the Sample App!"
      redirect_to user_path(@user)
      # render "show"
    else
      flash.now[:warning] = "No account created!"
      render 'new', status: :unprocessable_entity
    end
    # debugger
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
