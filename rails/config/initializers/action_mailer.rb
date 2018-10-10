# frozen_string_literal: true

# Action Mailer configuration
#
# Resources:
# * [Rails Guide](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail)
# * [G Suite SMTP settings to send mail from a printer, scanner, or app](https://support.google.com/a/answer/176600?hl=en)
# * [Gitlab SMTP settings](https://docs.gitlab.com/omnibus/settings/smtp.html)
#
# TODO:
# * Requires setting "Allow less secure apps: ON" at (https://myaccount.google.com/u/1/security)
Rails.application.configure do
  # Defaults to:
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.perform_deliveries = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587, # TLS supercedes SSL across GSuite
    domain: ENV.fetch('SMTP_DOMAIN') { 'tiu11.org' },
    authentication: :plain,
    enable_starttls_auto: true,
    user_name: ENV['SMTP_USER'], # ex. 'user@gmail.com'
    password: ENV['SMTP_PASSWORD']
  }
end
