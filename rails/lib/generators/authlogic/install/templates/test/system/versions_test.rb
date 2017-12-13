require "application_system_test_case"

class VersionsTest < ApplicationSystemTestCase
  test 'Public cannot view versions list' do
    visit versions_path
    assert_selector 'p.alert-warning', text: I18n.t('app.messages.require_user')
  end

  test 'Admin can view versions list' do
    user = FactoryBot.create(:admin)
    as_user(user) do
      visit versions_path

      assert_selector 'h1', text: 'Revision History'
    end
  end
end
