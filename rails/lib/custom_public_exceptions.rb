class CustomPublicExceptions < ActionDispatch::PublicExceptions

  def call(env)
    begin
      @exception   = env['action_dispatch.exception']
      @status_code = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
      %@app_name%::Application.routes.recognize_path("/#{@status_code}")
      %@app_name%::Application.routes.call env # Look for a route to a custom error handler
    rescue ActionController::RoutingError => e
      Rails.logger.debug "No route for #{@status_code}. Falling back to defaults."
      super env
    rescue Exception => e
      # TODO: invoke ExceptionNotifier
      Rails.logger.fatal "Exception during custom error handling, '#{e}'. Falling back to defaults."
      Rails.logger.fatal "#{e.class} (#{e.message})\n  " +
          e.backtrace.join("\n  ")
      super env
    end
  end

end
