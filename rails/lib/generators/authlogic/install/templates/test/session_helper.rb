module SessionHelper
  # Login as the given user. Asserts successful login message.
  def login_as(user)
    visit login_url
    fill_in 'Username', with: user.username
    fill_in 'Password', with: user.password

    click_button 'Log In'

    assert_text 'Welcome to '
  end

  # Logout of current session
  def logout
    visit logout_url
  end

  # Wrap login for given user around block
  def as_user(user)
    login_as(user)
    yield
    logout
  end
end
