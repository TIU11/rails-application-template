# Action Mailer
# https://support.google.com/a/answer/176600?hl=en
# http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
Rails.application.configure do
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'tiu11.org',
    user_name: ENV['GOOGLE_SMTP_USER'],
    password: ENV['GOOGLE_SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
end
