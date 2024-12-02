class SessionsController < ApplicationController
  def new
  end

  #ログイン
  #(仮想のremember_token属性にアクセスするために)テストからuserにアクセスするために、ローカル変数からインスタンス変数に変える
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      reset_session
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
      log_in @user
      redirect_to forwarding_url || @user
    else
      #エラーメッセージ送信
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end
  
  #ログアウト
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
    