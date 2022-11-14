# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from:     -> { default_from },
          reply_to: -> { default_reply_to }

  layout 'mailer' # All mailers will share a layout

  # Include view helpers
  #
  # Avoids add_template_helper, which was removed in Rails 6.1
  # See https://github.com/rails/rails/commit/cb3b37b37975ceb1d38bec9f02305ff5c14ba8e9

  include AnalyticsHelper
  helper AnalyticsHelper

  include DateRangeHelper # for :date_range method
  helper DateRangeHelper

  include DateTimeHelper # for :readable_date method
  helper DateTimeHelper

  delegate :default_from, :default_reply_to, to: :class

  class << self
    # NOTE: Gmail always sends from the authenticated user, unless the other address is added and verified with Google:
    # - https://support.google.com/mail/answer/22370?hl=en
    def default_from
      email_address_with_name(
        smtp_settings[:user_name],
        "#{I18n.t('app.title')} #{Rails.env.upcase unless Rails.env.production?}".squish
      )
    end

    def default_reply_to
      email_address_with_name(
        I18n.t('app.support_email'),
        "#{I18n.t('app.title')} #{Rails.env.upcase unless Rails.env.production?}".squish
      )
    end
  end

  private

    def prevent_delivery_when_no_recipients
      raise(LoadError, 'requires ActionMailbox for :recipients method') unless defined?(ActionMailbox)
      return if mail.recipients.present?

      Rails.logger.warn "Dropping email because it has no recipients: '#{mail.subject}'"
      mail.perform_deliveries = false
    end

    # Adds analytics parameters to default url options included in all generated urls.
    # Within the mailer action you call this, will make all link or image hrefs include the source, medium, etc.
    #
    # Defaults:
    # - utm_medium: 'email'
    # - utm_source: action name of the current Mailer
    # Reference:
    # - https://support.google.com/analytics/answer/1033863?hl=en#zippy=%2Cin-this-article
    # - https://developers.google.com/analytics/devguides/collection/analyticsjs/field-reference
    def analytics_url_params(**options)
      raise ArgumentError, "must be a Hash" unless options.is_a? Hash

      options.with_defaults! utm_medium: :email, utm_source: action_name
      self.default_url_options = default_url_options.merge(**options)
    end

end
