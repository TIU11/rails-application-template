require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test 'User can view own account' do
    user = FactoryBot.create(:user)
    as_user(user) do
      visit account_path
      assert_selector 'h2', text: user.name
    end
  end

  test 'Admin can view users list' do
    user = FactoryBot.create(:admin)
    as_user(user) do
      visit users_path

      assert_selector 'h2', text: 'Users'
      assert_text user.email
    end
  end
end
