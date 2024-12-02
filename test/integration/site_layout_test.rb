require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
  #このlayout linksはこのテスト自体の名前だからなんでもいい
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", users_path, count: 0
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
    get root_path
    log_in_as(@user)
    #ログインの処理の時にユーザーのページにリダイレクトが飛んでいるからテストでは自動的に行えないリダイレクトをさせなきゃいけなかった
    follow_redirect!
    assert_select "a[href=?]", users_path, count: 1
  end
end
