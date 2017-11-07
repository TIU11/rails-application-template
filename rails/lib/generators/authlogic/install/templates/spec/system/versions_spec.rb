require 'rails_helper'

RSpec.feature "Versions", type: :system do

  it 'can list versions' do
    user = FactoryBot.create(:admin)
    as_user(user) do
      visit versions_url
      expect(page).to have_content('Revision History')
    end
  end

end
