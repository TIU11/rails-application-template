# frozen_string_literal: true

# Pry Console Aliases
# Inspired by https://pawelurbanek.com/rails-console-aliases

def me
  @me ||= User.find_by(username: `git config user.email`.strip)
end
