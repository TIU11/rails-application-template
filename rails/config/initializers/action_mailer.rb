# Action Mailer
Rails.application.configure do
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: 'mr.tiu11.org',
    domain: 'tiu11.org'
  }
end
