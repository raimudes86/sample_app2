require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil（only cookies login）" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  #刻まれてる暗号化済み記憶トークンを勝手に書き換えるとログインがうまくいかないことの検知
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end