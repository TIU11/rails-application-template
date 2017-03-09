# [Rails Guide](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail)
#
# [G Suite SMTP settings to send mail from a printer, scanner, or app](https://support.google.com/a/answer/176600?hl=en)
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
    domain: 'tiu11.org',
    authentication: :plain,
    enable_starttls_auto: true,
    user_name: ENV['GMAIL_USER'], # ex. 'user@gmail.com'
    password: ENV['GMAIL_PASSWORD']
  }
end
