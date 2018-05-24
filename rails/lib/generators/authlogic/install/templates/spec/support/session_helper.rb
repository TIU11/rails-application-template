# frozen_string_literal: true

def login_as(user)
  visit login_url
  fill_in 'Username', with: user.username
  fill_in 'Password', with: user.password
  click_button 'Log In'
  expect(page).to have_content('Welcome to ')
end

def logout
  visit logout_url
end

def as_user(user)
  login_as(user)
  yield
  logout
end
