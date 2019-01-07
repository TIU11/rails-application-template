# frozen_string_literal: true

# Login as the given user. Expects successful login message.
def login_as(user)
  visit login_url

  expect(page).to have_content('Login')
  fill_in 'Username', with: user.username
  fill_in 'Password', with: user.password

  click_button 'Log In'

  expect(page).to have_content(I18n.t('app.messages.welcome'))
end

# Logout of current session. Expects logout message.
def logout
  visit logout_url
  expect(page).to have_content(I18n.t('app.messages.logout'))
end

# Wrap login for given user around block
def as_user(user)
  login_as(user)
  yield
  logout
end
