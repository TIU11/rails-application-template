# frozen_string_literal: true

puts 'Verifying prerequisite gems used within this template'
%w[byebug colorize].each do |gemname|
  next if Gem::Specification.find_all_by_name(gemname).present?

  run "gem install #{gemname}"
  Gem.refresh
  Gem.try_activate(gemname)
end

require 'byebug'
require 'colorize'
require 'rails'

say_status :rails_version, Rails.version

say set_color('Download template files from Bitbucket', :cyan)
git archive: '--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar -v master:rails | (tar xf -)'

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
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.asset_host = "http://localhost:3000" # for image URLs in HTML email

  # Allow generating absolute urls with routing url helpers.
  Rails.application.default_url_options = { host: 'localhost', port: 3000 }

  # Limit log size, rotating at 5 MB
  config.logger = Logger.new(config.paths['log'].first, 1, 5.megabytes)

  # Enable Bullet which reports N+1 queries to the browser.
  # TODO: prevent by running in tests: https://github.com/flyerhzm/bullet#run-in-tests
  config.enable_bullet = false
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
if File.exist? 'config/secrets.yml'
  insert_into_file 'config/secrets.yml', %(
  dev:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

  demo:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

  ), before: /(\s+#.*\n)+\s*production:\n/ # before production config and comments
end
insert_into_file 'config/database.yml', %(
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV.fetch('DATABASE_HOST', 'localhost') %>
), after: /^default: &default\n(  \w+:.*\n)+/ # at end of 'default' block
insert_into_file 'config/database.yml', %(
dev:
  <<: *default
  database: #{@app_name}_development
  username: #{@app_name}

demo:
  <<: *default
  database: #{@app_name}_demo
  username: #{@app_name}

), before: /(#.*\n)+\s*production:\n/ # before production config and comments

# Routes
route "root to: 'exception#not_found'"
route "get '/404' => 'exception#not_found'"
route "get '/500' => 'exception#internal_server_error'"

say set_color('Process Templates', :cyan)
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
remove_file 'config/initializers/secret_token.rb' #
# Unused files from Rails default template
remove_file 'app/assets/images/rails.png'
remove_file 'public/index.html'

#
# Create and initialize RVM gemset
# @see https://rvm.io/workflow/scripting for explanation of `rvm do`
#
say set_color('Setting up RVM gemset', :cyan)
default_ruby = `rvm list default string`.strip # default to `rvm default` ruby version
@desired_ruby = ask("Which Ruby would you like to use? [#{default_ruby}]".cyan)
@desired_ruby = default_ruby if @desired_ruby.blank?
if `rvm list strings`.include? @desired_ruby
  puts "#{@desired_ruby} already installed"
else
  run "rvm install #{@desired_ruby}"
end
@gemset = "#{@desired_ruby}@#{app_name.titleize.parameterize}"
run "rvm #{@desired_ruby} do rvm --ruby-version --create use #{@gemset}"
@rvm_do = "rvm #{@gemset} do" # run a command within this gemset via `run "#{@rvm_do} command"`

# Run commands within our app's RVM gemset
# Hacks Rails::Generators::Actions.execute_command via extify
# - https://github.com/rails/rails/blob/6-0-stable/railties/lib/rails/generators/actions.rb#L285
# - https://github.com/rails/rails/blob/6-0-stable/railties/lib/rails/generators/actions.rb#L299
# - http://stackoverflow.com/questions/11302742/how-to-make-a-rails-template-forcefully-not-run-bundle-install-after-rails-new-i
def extify(action)
  say_status :rvm, "Executing #{action.inspect} in RVM gemset #{@gemset}"
  "#{@rvm_do} #{super}"
end

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

  # Workaround `yarn check --integrity` failing due to template edits to package.json
  # - https://github.com/key-sn/webpacker/blob/master/lib/webpacker/railtie.rb#L33
  `yarn` if File.exist?("yarn.lock")
end

# Override bundle command to run in context of current RVM gemset
# https://github.com/rails/rails/blob/6-0-stable/railties/lib/rails/generators/app_base.rb#L352
def exec_bundle_command(bundle_command, command, env)
  full_command = %(#{@rvm_do} "#{bundle_command}" #{command})
  if options[:quiet]
    system(env, full_command, out: File::NULL)
  else
    system(env, full_command)
  end
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

  # Setup the app how we like it
  generate "tiu:app:setup"

  # Create the environments and database before papertrail which check db.
  rails_command "app:create_dotenv"
  rails_command "db:create"

  if yes?('Create Users? [yN]'.cyan)
    generate "tiu:authlogic:install", "--force"
  end

  # Add code to the repository
  puts "\nNow is a good time to review the generated application,"\
       'and make manual changes described in the README before continuing'.yellow
  if yes?('Are you ready to commit? [yN]'.cyan)
    git :init
    git add: '--all .'
    git commit: "-m 'Applied Rails Application Template'"
  end

  rails_command "db:migrate"
  rails_command "bitbucket:setup"
  rails_command "bitbucket:launch_sourcetree"

  puts "\nNow is a good time to run the generated application, and fix anything wonky before deploying".yellow
  if yes?('Deploy? [yN]'.cyan)
    bundle_command "exec cap dev rvm:create_gemset"
    bundle_command "exec cap dev deploy:setup"
    bundle_command "exec cap dev deploy"
  end

  say_status :end, "#{@app_name} Complete! 🎉🚀"
end

say_status :end, "#{@app_name} template applied! Now bundler will install to the #{@gemset} gemset."
