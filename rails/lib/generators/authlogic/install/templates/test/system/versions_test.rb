require "application_system_test_case"

class VersionsTest < ApplicationSystemTestCase
  test 'Public cannot view versions list' do
    visit versions_path
    assert_selector 'p.alert-warning', text: I18n.t('app.messages.require_user')
  end

  test 'Users cannot view versions list' do
    user = FactoryBot.create(:user)
    as_user(user) do
      visit versions_path

      assert_selector 'p.alert-danger', text: 'As a regular user, you are not authorized to list Paper Trail/Versions.'
    end
  end

  test 'Admin can view versions list' do
    user = FactoryBot.create(:admin)
    as_user(user) do
      visit versions_path

      assert_selector 'h1', text: 'Revision History'
    end
  end
end
