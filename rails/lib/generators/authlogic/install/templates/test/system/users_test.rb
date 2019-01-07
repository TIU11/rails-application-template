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

  test 'Admin can create a user' do
    user = FactoryBot.create(:admin)
    user2 = FactoryBot.build(:user)

    as_user(user) do
      visit users_path

      click_link 'New User'
      assert_selector 'h2', text: 'New user'

      fill_in 'Email', with: user2.email
      fill_in 'First name', with: user2.first_name
      fill_in 'Middle name', with: user2.middle_name
      fill_in 'Last name', with: user2.last_name

      click_button 'Create'
      assert_selector 'h2', text: user2.to_s
    end
  end
end
