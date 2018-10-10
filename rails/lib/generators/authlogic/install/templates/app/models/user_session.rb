# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  # See https://www.rubydoc.info/github/binarylogic/authlogic/Authlogic/Session/Password/Config
  find_by_login_method :find_by_username_or_email

  logout_on_timeout true
  generalize_credentials_error_messages true
end
