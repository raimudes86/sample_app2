class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #セキュリティ対策で
      #flashメッセージを入れた後にresetするとフラッシュメッセージも消えるから順番に注意
      reset_session
      log_in @user
      flash[:success] = "Welcom to the Sample App!"
      redirect_to user_path(@user)
      # render "show"
    else
      # flash.now[:warning] = "No account created!"
      render 'new', status: :unprocessable_entity
    end
    # debugger
  end

  #beforeactionで定義しているから@userはいらない
  def edit
    # @user = User.find(params[:id])
  end
  #beforeactionで定義しているから@userはいらない
  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    #beforeフィルタ
    #ログイン済みユーザーかどうかを確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end

    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
  end
