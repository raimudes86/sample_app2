require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
      email: "user@invalid",
      password: "foo",
      password_confirmation: "bar"} }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count' do
      post users_path, params: { user: {name: "kinoshita",
                                        email: "raijirou12@gmail.com",
                                        password: "raimU0924",
                                        password_confirmation: "raimU0924"}
      }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?, "flash should be empty after rendering true view"
    assert is_logged_in?
  end
end
