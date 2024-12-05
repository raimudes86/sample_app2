class RelationshipsController < ApplicationController
    before_action :logged_in_user
    #フォロー
    def create
        @user = User.find(params[:followed_id])
        current_user.follow(@user)
        respond_to do |format|
            format.html { redirect_to @user}
            format.turbo_stream
        end
    end
    
    #フォロー解除
    #idはフォロー解除する時のフォームで、activeの集合から(followingのrelationの集合の中から)消したいユーザーについてのrelationのid)を渡している
    #つまりここでは、その消したいリレーション(自分がその人をフォローしている)のうちの、フォローされてる側をuserに入れる
    #unfollowでは、その渡された人のリレーション(followingの中の一つ)をdeleteで消してくれる
    def destroy
        @user = Relationship.find(params[:id]).followed
        current_user.unfollow(@user)
        respond_to do |format|
            format.html { redirect_to @user, status: :see_other}
            format.turbo_stream
        end
    end
end
