require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "valid signup information with account activation" do
    get signup_path
	assert_difference 'User.count', 1 do
	  post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
	end
	assert_equal 1, ActionMailer::Base.deliveries.size
	user = assigns(:user)
	assert_not user.activated?
	log_in_as(user)
	assert_not is_logged_in?
	get edit_account_activation_path("invalid token", email: user.email)
	assert_not is_logged_in?
	get edit_account_activation_path(user.activation_token, email: 'wrong')
	assert_not is_logged_in?
	get edit_account_activation_path(user.activation_token, email: user.email)
	assert user.reload.activated?
	follow_redirect!
	assert_template 'users/show'
	assert is_logged_in?
    #assert_select "div#error_explanation", "Name can't be blank\nEmail is invalid\nPassword confirmation dosen't match Password\nPassword is too short(minimum is 6 characters)"
  end
end
