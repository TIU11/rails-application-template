#
# Gemfile
#
gem 'authlogic'
gem 'cancan'
gem 'friendly_id'
gem 'will_paginate'
gem 'exception_notification'
gem 'underscore-rails'
gem 'active_model_serializers'
gem 'dotenv-rails'

gem_group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'

  # Use 'thin' to avoid "Could not determine content-length of response body." warnings.
  # See http://stackoverflow.com/questions/7082364/what-does-warn-could-not-determine-content-length-of-response-body-mean-and-h
  gem 'thin'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_best_practices'
  gem 'pry-rails'
end

gem_group :assets do
  gem 'compass-rails', '~> 1.0.3'

  gem 'therubyracer', :platforms => :ruby
  gem 'less-rails' # For Twitter Bootstrap
  gem 'twitter-bootstrap-rails'
end

#
# Config Files
#

# Download template files
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"
gsub_file 'lib/custom_public_exceptions.rb', "%@app_name.camelize%", @app_name.camelize

#
# Configure Environments
#
application <<-CONFIG
    # Action Mailer
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      :address => 'mr.tiu11.org',
      :domain => 'tiu11.org'
    }
    config.action_mailer.default_url_options = {
      :host => "localhost:3000"
    }
    config.action_mailer.asset_host = "http://localhost:3000/"

    # Exception Handler
    require "custom_public_exceptions"
    config.exceptions_app = CustomPublicExceptions.new Rails.public_path
CONFIG

copy_file "#{destination_root}/config/environments/production.rb", "#{destination_root}/config/environments/demo.rb"
uncomment_lines "config/environments/production.rb", "config.force_ssl = true"

#
# Remove Junk
#
remove_file 'app/assets/images/rails.png'

#
# Generate and Setup
#
generate 'exception_notification:install'
generate 'cancan:ability'
run "capify ."
generate 'bootstrap:install less'

say_status :end, "#{@app_name} Complete!"
