# frozen_string_literal: true

# insert middleware wherever you want in the stack, optionally pass
# initialization arguments, or use environment variables
unless Rails.env.in? %w[development test]
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 120.seconds.to_i
end
