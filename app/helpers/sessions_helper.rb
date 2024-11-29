module SessionsHelper
    #渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id
        session[:session_token] = user.session_token
    end

    #永続的セッションのためにユーザーをDBに記憶する
    #user.rememberによってremember_tokenが生成される
    def remember(user)
        user.remember
        cookies.permanent.encrypted[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    #永続的セッションを破棄する
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    #現在ログイン中のユーザーを返す(いる場合)
    #ログインしているユーザーがいる→current_userに入っていなければ入れる、入っていればそのまま
    #ログインしてなければ、永続的クッキーから復号したuidを取得、存在すれば、DBから引っ張ってくる
    #永続的クッキーの記憶トークンの平文を暗号化したものとuserのremember_digestが同じなら、ログインする
    def current_user
        if (user_id = session[:user_id])
            user = User.find_by(id: user_id)
            if user && session[:session_token] == user.session_token
                @current_user = user
            end
        elsif (user_id = cookies.encrypted[:user_id])
            # raise
            user = User.find_by(id: user_id)
            if user && user.token_authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    #ユーザーがログインしていなければ、true,その他ならfalseを返す
    def logged_in?
        !current_user.nil?
    end

    #この@なしのcurrent_userは、上で定義している今のカレントユーザーを取得するメソッドのことである！！
    def log_out
        forget(current_user)
        reset_session
        @current_user = nil
    end
end
