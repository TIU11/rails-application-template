require 'logging_utility'

class CustomPublicExceptions < ActionDispatch::PublicExceptions

  def call(env)
    @exception   = env['action_dispatch.exception']
    @status_code = ActionDispatch::ExceptionWrapper.new(Rails.backtrace_cleaner, @exception).status_code
    Rails.application.routes.recognize_path("/#{@status_code}")
    Rails.application.routes.call env # Look for a route to a custom error handler
  rescue ActionController::RoutingError
    Rails.logger.debug { "No route for #{@status_code}. Falling back to default exception handling." }
    super env
  rescue RuntimeError => e
    LoggingUtility.notify(e, 'Exception during custom error handling. Falling back to defaults.')
    super env
  end

end
