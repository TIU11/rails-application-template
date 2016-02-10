puts "Verify prerequisite gems used within this template"
%w{byebug colorize}.each do |gemname|
  if Gem::Specification.find_all_by_name(gemname).empty?
    run "gem install #{gemname}"
    Gem.refresh
    Gem.try_activate(gemname)
  end
end

require 'byebug'
require 'colorize'
require 'rails'

say_status :rails_version, Rails.version

puts "Download template files from Bitbucket".cyan
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"

# .gitignore
append_to_file '.gitignore', %{
.byebug_history
.env
}

#
# Configurations
#

# config/application.rb
insert_into_file 'config/application.rb', open('config/application.rb.delta').read, before: "  end"
gsub_file 'config/application.rb',
          "# config.time_zone = 'Central Time (US & Canada)'", "config.time_zone = 'Eastern Time (US & Canada)'"
remove_file 'config/application.rb.delta'

# config/initializers/filter_parameter_logging.rb
gsub_file 'config/initializers/filter_parameter_logging.rb',
          '[:password]', '[:password, :password_confirmation]'

# config/environments/*

insert_into_file 'config/environments/development.rb', <<-CONFIG, before: /^end/

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Action Mailer
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.asset_host = "http://localhost:3000" # for image URLs in HTML email
CONFIG
gsub_file 'config/environments/development.rb', 'config.assets.debug = true', 'config.assets.debug = false'

uncomment_lines "config/environments/production.rb", "config.force_ssl = true"
insert_into_file 'config/environments/production.rb', <<-CONFIG, before: /^end/

  # Action Mailer
  config.action_mailer.default_url_options = { host: '#{app_name.titleize.parameterize}.tiu11.org' }
  config.action_mailer.asset_host = "http://#{app_name.titleize.parameterize}.tiu11.org" # for image URLs in HTML email
CONFIG

# Initialize "dev" and "demo" environments
copy_file "#{destination_root}/config/environments/production.rb",
          "#{destination_root}/config/environments/dev.rb"
copy_file "#{destination_root}/config/environments/production.rb",
          "#{destination_root}/config/environments/demo.rb"
insert_into_file 'config/secrets.yml', %{
dev:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

demo:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

}, before: /(#.*\n)+production:\n/ # before production config and comments
insert_into_file 'config/database.yml', %{
dev:
  <<: *default
  database: #{@app_name}_development
  username: #{@app_name}
  password: <%= ENV['DATABASE_PASSWORD'] %>

demo:
  <<: *default
  database: #{@app_name}_demo
  username: #{@app_name}
  password: <%= ENV['DATABASE_PASSWORD'] %>

}, before: /(#.*\n)+production:\n/ # before production config and comments

#
# Asset Pipeline
#

insert_into_file "#{destination_root}/app/assets/javascripts/application.js", <<-JS, after: "//= require jquery_ujs\n"
//= require underscore
//= require bootstrap-sprockets
//= require bootstrap-datepicker
JS

insert_into_file 'app/assets/stylesheets/application.css',
                 " *= require bootstrap-datepicker3\n",
                 after: " *= require_self\n"

# Routes
route "root to: 'exception#show'"
route "get '/404' => 'exception#show'"

puts "Process Templates".cyan
template    "#{destination_root}/config/locales/en.yml.tt"
remove_file "#{destination_root}/config/locales/en.yml.tt"
template    "#{destination_root}/config/initializers/exception_notification.rb.tt"
remove_file "#{destination_root}/config/initializers/exception_notification.rb.tt"
template    "#{destination_root}/config/deploy.rb.tt"
remove_file "#{destination_root}/config/deploy.rb.tt"
template    "#{destination_root}/config/sitemap.rb.tt"
remove_file "#{destination_root}/config/sitemap.rb.tt"

puts "Remove Junk/Unwanted Files".cyan
# Replaced by secrets.yml (http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#config-secrets-yml)
remove_file 'config/initializers/secret_token.rb' #
# Unused files from Rails default template
remove_file 'app/assets/images/rails.png'
remove_file 'public/index.html'

#
# Create and initialize RVM gemset
# @see https://rvm.io/workflow/scripting for explanation of `rvm do`
#
puts "Setting up RVM gemset".cyan
default_ruby = `rvm strings 2`.strip # default to latest 2.x ruby version (e.g. '2.2.2', '2.3.0')
@desired_ruby = ask("Which Ruby would you like to use? [#{default_ruby}]".cyan)
@desired_ruby = default_ruby if @desired_ruby.blank?
if `rvm list strings`.include? @desired_ruby
  puts "#{@desired_ruby} already installed"
else
  run "rvm install #{@desired_ruby}"
end
gemset_name = app_name.titleize.parameterize
run "rvm #{default_ruby} do rvm --ruby-version --create use #{@desired_ruby}@#{gemset_name}"
@rvm_do = "rvm #{@desired_ruby}@#{gemset_name} do" # run a command within this gemset via `run "#{@rvm_do} command"`

# Override since Rails won't install into our project's RVM gemset
# See http://apidock.com/rails/v4.2.1/Rails/Generators/AppBase/run_bundle
# See http://stackoverflow.com/questions/11302742/how-to-make-a-rails-template-forcefully-not-run-bundle-install-after-rails-new-i
def run_bundle
  puts "Updating to the latest Rubygems".cyan
  puts "Currently using Rubygems #{`#{@rvm_do} gem -v`}"
  run "#{@rvm_do} rvm rubygems latest"

  puts "Updating to the latest Bundler".cyan
  run "rvm #{@desired_ruby}@global do gem install bundler"

  return unless bundle_install? # respect `--skip-bundle` flag
  puts "Installing bundled gems (may take several minutes)".cyan
  say_status :run, "#{@rvm_do} bundle install"

  require 'bundler'
  Bundler.with_clean_env do
    run "#{@rvm_do} bundle install"
  end
end

# Override since Rails won't run this within the project's RVM gemset
# See http://apidock.com/rails/Rails/Generators/AppBase/generate_spring_binstubs
def generate_spring_binstubs
  if bundle_install? && spring_install?
    say_status :run, "#{@rvm_do} bundle exec spring binstub --all"
    run "#{@rvm_do} bundle exec spring binstub --all"
  end
end

#
# Generate and Setup
#

after_bundle do
  puts "Run generators".cyan

  # Keep the rspec generator from hanging.
  # @see (http://www.sitepoint.com/rails-application-templates-real-world/)
  run "#{@rvm_do} spring stop"
  # Install rspec
  run "#{@rvm_do} rails generate rspec:install"

  if yes?("Create Users? [yN]".cyan)
    run "#{@rvm_do} rails generate paper_trail:install"
    run "#{@rvm_do} rails generate authlogic:install --force"
  end

  # Add code to the repository
  puts "\nNow is a good time to review the generated application, and make manual changes described in the README before continuing".yellow
  if yes?("Are you ready to commit? [yN]".cyan)
    git add: '--all .', commit: "-m 'Applied Rails Application Template'"
  end

  run "#{@rvm_do} rake db:create"
  run "#{@rvm_do} rake db:migrate"
  run "#{@rvm_do} rake bitbucket:setup"
  run "#{@rvm_do} rake bitbucket:launch_sourcetree"

  if yes?("Deploy? [yN]".cyan)
    run "#{@rvm_do} cap dev rvm:create_gemset"
    run "#{@rvm_do} cap dev deploy:setup"
    run "#{@rvm_do} cap dev deploy"
  end
end

say_status :end, "#{@app_name} Complete!"
