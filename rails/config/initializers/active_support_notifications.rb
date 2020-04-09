# https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
# https://guides.rubyonrails.org/active_support_instrumentation.html

# Log Rack::Attack throttling
# https://github.com/kickstarter/rack-attack#logging--instrumentation
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |event|
  request = event.payload[:request]
  Rails.logger.info <<~MSG
    [Rack::Attack][Throttle] #{request.request_method} #{request.path} from #{request.ip}
      Parameters: #{request.params}
  MSG
end

# Log Active Job failures
# https://guides.rubyonrails.org/active_support_instrumentation.html#discard-active-job
ActiveSupport::Notifications.subscribe('discard.active_job') do |event|
  _adapter, job, error = event.payload.fetch_values :adapter, :job, :error
  Rails.logger.error "[ActiveJob][Discard] #{job.class} [#{job.job_id}] #{error.class} - #{error.message}"
end
