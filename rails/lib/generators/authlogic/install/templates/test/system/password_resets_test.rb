require "application_system_test_case"

class PasswordResetsTest < ApplicationSystemTestCase
  test "request a Password Reset" do
    user = FactoryBot.create :user

    visit login_url
    click_link 'Forgot your password?'

    assert_selector "h2", text: "Request a Password Reset"
    fill_in 'Username', with: user.username
    fill_in 'Registered Email', with: user.email

    click_button 'Email my password reset'

    assert_selector "p.alert.alert-info", text: I18n.t('app.messages.password_reset.sent_email')
  end
end
