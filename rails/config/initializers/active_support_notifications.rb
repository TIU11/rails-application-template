# https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
# https://guides.rubyonrails.org/active_support_instrumentation.html

# Log Rack::Attack throttling
# https://github.com/kickstarter/rack-attack#logging--instrumentation
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |event|
  request = event.payload[:request]
  match_type = request.env['rack.attack.match_type']
  matched_key = request.env['rack.attack.matched']
  match_data = request.env['rack.attack.match_data']
  filtered_params = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
                                                  .filter(request.params)
  Rails.logger.warn <<~MSG
    [Rack::Attack][#{match_type.capitalize}] "#{matched_key}" #{match_type} on #{request.request_method} "#{request.path}" from #{request.ip}
      Parameters: #{filtered_params}
      Match Data: #{match_data}
  MSG
end

# Log Active Job failures
# https://guides.rubyonrails.org/active_support_instrumentation.html#discard-active-job
ActiveSupport::Notifications.subscribe('discard.active_job') do |event|
  _adapter, job, error = event.payload.fetch_values :adapter, :job, :error
  Rails.logger.error "[ActiveJob][Discard] #{job.class} [#{job.job_id}] #{error.class} - #{error.message}"
end
