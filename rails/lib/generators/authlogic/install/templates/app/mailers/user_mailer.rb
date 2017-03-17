class UserMailer < ApplicationMailer
  add_template_helper(AnalyticsHelper)
  default from: I18n.t('app.sending_email'),
          reply_to: I18n.t('app.support_email')

  def password_reset(user)
    Rails.logger.info {"Sending password reset email to #{user}"}

    @user = user
    @new_password_reset_url = new_password_reset_url(
      # Params for Analytics:
      utm_source: 'password_reset',
      utm_medium: 'email')
    @edit_password_reset_url = edit_password_reset_url(
        user.perishable_token,
        # Params for Analytics:
        utm_source: 'password_reset',
        utm_medium: 'email')
    mail(to: user.email, subject: "#{I18n.t('app.title')} Password Reset")
  end
end
