# frozen_string_literal: true

# IRB Console Aliases
# Inspired by https://pawelurbanek.com/rails-console-aliases

def me
  @me ||= User.find_by(email: `git config user.email`.strip)
end

# Banner for production console
# @see https://x.com/_swanson/status/1346851840944730112
if defined?(Rails) && Rails.env.production?
  banner = "\e[41;97;1m #{Rails.env} \e[0m "

  # Build a custom prompt
  IRB.conf[:PROMPT][:CUSTOM] = IRB.conf[:PROMPT][:DEFAULT].merge(
    PROMPT_I: banner + IRB.conf[:PROMPT][:DEFAULT][:PROMPT_I],
  )

  # Use custom prompt by default
  IRB.conf[:PROMPT_MODE] = :CUSTOM
end
