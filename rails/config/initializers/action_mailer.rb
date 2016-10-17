# Action Mailer
Rails.application.config.action_mailer do |action_mailer|
  action_mailer.delivery_method = :sendmail
  action_mailer.perform_deliveries = true
  action_mailer.raise_delivery_errors = true
  action_mailer.smtp_settings = {
    address: 'mr.tiu11.org',
    domain: 'tiu11.org'
  }
end
