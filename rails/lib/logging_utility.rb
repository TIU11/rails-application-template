module LoggingUtility

  class << self

    # Sends exception to exception_notifier along with context information.
    # Logs the backtrace to aid troubleshooting.
    #
    # Usage: notify(RuntimeError, message: 'We have a problem')
    def notify(exception, message: nil)
      backtrace = Rails.backtrace_cleaner.filter(exception.backtrace)
      data = { application: I18n.t('app.title'), environment: Rails.env, message: message }

      Rails.logger.error <<~MESSAGE.strip
        #{exception.class} - #{exception.message}:
          #{backtrace.join("#{$/}  ")}
      MESSAGE

      ExceptionNotifier.notify_exception(exception, env: Rails.env, data: data)
    end

  end

end
