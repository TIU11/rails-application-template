# frozen_string_literal: true

say_status :rails_version, Gem::Specification.find_by_name('rails').version

say set_color('Download template files from GitHub', :cyan)
git archive: '--remote=git@github.com:TIU11/rails-application-template.git --format=tar -v master:rails | (tar xf -)'

#
# Configurations
#

# config/application.rb
insert_into_file 'config/application.rb', open('config/application.rb.delta').read, before: '  end'
remove_file 'config/application.rb.delta'

# config/initializers/filter_parameter_logging.rb
gsub_file 'config/initializers/filter_parameter_logging.rb',
          '[:password]', '[:password, :password_confirmation]'

# config/environments/*

# TODO: insert portions into config/environments/test.rb
insert_into_file 'config/environments/development.rb', <<-CONFIG, before: /^end/

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Action Mailer
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 } # mailpit
  config.action_mailer.asset_host = "http://localhost:3000" # for image URLs in HTML email

  # Allow generating absolute urls with routing url helpers.
  Rails.application.default_url_options = { host: 'localhost', port: 3000 }

  config.active_record.strict_loading_by_default = true
CONFIG
gsub_file 'config/environments/development.rb', 'config.assets.debug = true', 'config.assets.debug = false'
uncomment_lines 'config/environments/development.rb', 'config.i18n.raise_on_missing_translations = true'
uncomment_lines 'config/environments/test.rb', 'config.i18n.raise_on_missing_translations = true'

uncomment_lines 'config/environments/production.rb', 'config.force_ssl = true'
insert_into_file 'config/environments/production.rb', <<-CONFIG, before: /^end/

  # Action Mailer
  config.action_mailer.default_url_options = { host: '#{app_name.titleize.parameterize}.tiu11.org' }
  config.action_mailer.asset_host = "http://#{app_name.titleize.parameterize}.tiu11.org" # for image URLs in HTML email

  # Allow generating absolute urls with routing url helpers.
  Rails.application.default_url_options = { host: '#{app_name.titleize.parameterize}.tiu11.org' }
CONFIG

# Initialize "dev" and "demo" environments

copy_file "#{destination_root}/config/environments/production.rb",
          "#{destination_root}/config/environments/dev.rb"
copy_file "#{destination_root}/config/environments/production.rb",
          "#{destination_root}/config/environments/demo.rb"

pattern = /^default: &default\n(  \w+:.*\n)+/ # at end of 'default' block
insert_into_file('config/database.yml', <<-MSG, after: pattern)
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV.fetch('DATABASE_HOST', 'localhost') %>
MSG

pattern = /(#.*\n)+\s*production:\n/ # before production config and comments
insert_into_file 'config/database.yml', <<-MSG, before: pattern
dev:
  <<: *default
  database: #{@app_name}_development
  username: #{@app_name}

demo:
  <<: *default
  database: #{@app_name}_demo
  username: #{@app_name}

MSG

# Routes
route "root to: 'exception#not_found'"
route "get '/404' => 'exception#not_found'"
route "get '/500' => 'exception#internal_server_error'"

say set_color('Process Templates', :cyan)
template    "#{destination_root}/Gemfile.tt"
remove_file "#{destination_root}/Gemfile.tt"
template    "#{destination_root}/config/locales/en.yml.tt"
remove_file "#{destination_root}/config/locales/en.yml.tt"
template    "#{destination_root}/config/locales/views/en.yml"
template    "#{destination_root}/config/initializers/exception_notification.rb.tt"
remove_file "#{destination_root}/config/initializers/exception_notification.rb.tt"
template    "#{destination_root}/config/deploy.rb.tt"
remove_file "#{destination_root}/config/deploy.rb.tt"
template    "#{destination_root}/config/sitemap.rb.tt"
remove_file "#{destination_root}/config/sitemap.rb.tt"

say set_color('Remove Junk/Unwanted Files', :cyan)
# Replaced by secrets.yml (http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#config-secrets-yml)
remove_file 'config/initializers/secret_token.rb' # Rails 3
# Replaced by encrypted credentials
remove_file 'config/secrets.yml' # Rails 4 - 5.2
# Unused files from Rails default template
remove_file 'app/assets/images/rails.png'
remove_file 'public/index.html'

if !File.exist?('.nvmrc')
  say 'Initialize .nvmrc'
  File.write('.nvmrc', 'lts/*')
end
#
# Create and initialize RVM gemset
# @see https://rvm.io/workflow/scripting for explanation of `rvm do`
#
say set_color('Setting up RVM gemset', :cyan)
default_ruby = `rvm list default string`.strip # default to `rvm default` ruby version
@desired_ruby = ask(set_color("Which Ruby would you like to use? [#{default_ruby}]", :cyan))
@desired_ruby = default_ruby if @desired_ruby.blank?
if `rvm list strings`.include? @desired_ruby
  puts "#{@desired_ruby} already installed"
else
  run "rvm install #{@desired_ruby}"
end
@gemset = "#{@desired_ruby}@#{app_name.titleize.parameterize}"
run "rvm #{@desired_ruby} do rvm --ruby-version --create use #{@gemset}"
Dir.glob(['.ruby-gemset.*', '.ruby-version.*']).each { |file| File.delete(file) } # cleanup RVM backups

require 'rvm' # https://github.com/rvm/rvm-gem
RVM.gemset_use! @gemset

# Before bundle, update Rubygems and Bundler.
# - https://github.com/rails/rails/blob/6-0-stable/railties/lib/rails/generators/app_base.rb#L406
def run_bundle
  say set_color('Updating to the latest Rubygems', :cyan)
  run "gem update --system"

  say set_color('Updating to the latest Bundler', :cyan)
  if Gem.ruby_version < Gem::Version.new('2.6')
    run "rvm #{@desired_ruby}@global do gem install bundler"
  else
    run "gem update bundler"
  end

  super
end

#
# Generate and Setup
#

after_bundle do
  say set_color('Run generators', :cyan)

  # Keep the rspec generator from hanging.
  # @see (http://www.sitepoint.com/rails-application-templates-real-world/)
  bundle_command "exec spring stop" if Gem::Specification.find_all_by_name('spring').present?

  # Install rspec
  generate "rspec:install"
  gsub_file "spec/rails_helper.rb", /config.fixture_path.*/, 'config.fixture_paths = [Rails.root.join("test/fixtures")]'
  insert_into_file "spec/rails_helper.rb", "require 'simplecov' # Load SimpleCov", after: /^# Add additional requires below this line.*\n/

  # Setup the app how we like it
  generate "tiu:app:setup"

  # Create the environments and database before papertrail which check db.
  rails_command "app:create_dotenv"
  rails_command "db:create"

  if yes?(set_color('Create Users? [yN]', :cyan))
    generate "tiu:authlogic:install", "--force"
  end

  # Add code to the repository
  say set_color("\n💡 Review the generated application. "\
                "Make manual changes described in the README.", :yellow)
  if yes?(set_color('Are you ready to commit? [yN]', :cyan))
    git :init
    git add: '--all .'
    git commit: "-m 'Applied Rails Application Template'"
  end

  rails_command "db:migrate"
  rails_command "bitbucket:setup"
  rails_command "bitbucket:launch_sourcetree"

  say set_color("\n💡 Run the generated application. Fix anything wonky before deploying.", :yellow)
  if yes?(set_color('Deploy? [yN]', :cyan))
    bundle_command "exec cap dev rvm:create_gemset"
    bundle_command "exec cap dev deploy:setup"
    bundle_command "exec cap dev deploy"
  end

  say_status :end, "#{@app_name} Complete! 🎉🚀"
end

say_status :end, "Template applied to #{@app_name}! Now bundler will install to the #{@gemset} gemset."
