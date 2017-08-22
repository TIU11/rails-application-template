module LoggingUtility

  class << self

    # Logs exception and backtrace to aid troubleshooting.
    # Sends exception to exception_notifier along with context information.
    #
    # Usage: notify(RuntimeError, message: 'We have a problem')
    def notify(exception, message: nil)
      data = { application: I18n.t('app.title'), environment: Rails.env, message: message }

      log(exception, message: message)

      ExceptionNotifier.notify_exception(exception, env: Rails.env, data: data)
    end

    # Logs exception and backtrace to aid troubleshooting.
    def log(exception, message: nil)
      backtrace = Rails.backtrace_cleaner.filter(exception.backtrace) if exception.backtrace

      Rails.logger.error <<~MESSAGE.strip
        #{message}
        #{exception.class} - #{exception.message}:
          #{backtrace&.join("#{$INPUT_RECORD_SEPARATOR}  ")}
      MESSAGE
    end

  end

end
