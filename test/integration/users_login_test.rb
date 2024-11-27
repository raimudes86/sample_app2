require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    asset_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
  end
end
