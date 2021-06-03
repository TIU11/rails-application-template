# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: I18n.t('app.sending_email'),
          reply_to: I18n.t('app.support_email')

  layout 'mailer' # All mailers will share a layout

  # Include view helpers
  #
  # Avoids add_template_helper, which was removed in Rails 6.1
  # See https://github.com/rails/rails/commit/cb3b37b37975ceb1d38bec9f02305ff5c14ba8e9

  include AnalyticsHelper
  helper AnalyticsHelper

  # TODO: upstream from PA STEM
  # include DateRangeHelper # for :date_range method
  # helper DateRangeHelper

  include DateTimeHelper # for :readable_date method
  helper DateTimeHelper

end
