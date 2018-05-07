# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  logout_on_timeout true
  generalize_credentials_error_messages true
end
