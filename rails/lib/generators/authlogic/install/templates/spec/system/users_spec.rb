require 'rails_helper'

RSpec.feature "Users", type: :system do

  it 'can view own account' do
    user = FactoryBot.create(:user)
    as_user(user) do
      visit account_path
      expect(page).to have_selector('h2', text: user.name)
    end
  end

  it 'can view users list' do
    user = FactoryBot.create(:admin)
    as_user(user) do
      visit users_path
      expect(page).to have_selector('h2', text: 'Users')
      expect(page).to have_content(user.email)
    end
  end

end
