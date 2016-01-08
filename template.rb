puts "Verify prerequisite gems used within this template"
%w{colored}.each do |gemname|
  if Gem::Specification.find_all_by_name(gemname).empty?
    run "gem install #{gemname}"
    Gem.refresh
    Gem.try_activate(gemname)
  end
end

require 'colored'
require 'rails'

say_status :rails_version, Rails.version

puts "Download template files from Bitbucket".cyan
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"


# .gitignore
append_to_file '.gitignore', %{
.byebug_history
.env
}

# Gemfile
append_to_file 'Gemfile', open('Gemfile.delta').read
comment_lines 'Gemfile', "jbuilder"
remove_file 'Gemfile.delta'

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

insert_into_file 'config/environments/development.rb',
    "  config.action_controller.action_on_unpermitted_parameters = :raise\n",
    before: /^end/
gsub_file 'config/environments/development.rb', 'config.assets.debug = true', 'config.assets.debug = false'

uncomment_lines "config/environments/production.rb", "config.force_ssl = true"

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

insert_into_file "#{destination_root}/app/assets/javascripts/application.js",
                 "//= require underscore\n//= require bootstrap-sprockets\n//= require bootstrap-datepicker\n",
                 after: "//= require jquery\n"
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
@rvm = "rvm #{@desired_ruby}@#{gemset_name}" # run subsequent commands within this gemset via `run "#{@rvm} do command"`

# Override since Rails won't install into our project's RVM gemset
# See http://apidock.com/rails/v4.2.1/Rails/Generators/AppBase/run_bundle
# See http://stackoverflow.com/questions/11302742/how-to-make-a-rails-template-forcefully-not-run-bundle-install-after-rails-new-i
def run_bundle
  puts "Updating to the latest Rubygems".cyan
  puts "Currently using Rubygems #{`#{@rvm} do gem -v`}"
  run "#{@rvm} do rvm rubygems latest"

  puts "Updating to the latest Bundler".cyan
  run "rvm #{@desired_ruby}@global do gem install bundler"

  return unless bundle_install? # respect `--skip-bundle` flag
  puts "Installing bundled gems (may take several minutes)".cyan
  say_status :run, "#{@rvm} do bundle install"

  require 'bundler'
  Bundler.with_clean_env do
    run "#{@rvm} do bundle install"
  end
end

# Override since Rails won't run this within the project's RVM gemset
# See http://apidock.com/rails/Rails/Generators/AppBase/generate_spring_binstubs
def generate_spring_binstubs
  if bundle_install? && spring_install?
    say_status :run, "#{@rvm} do bundle exec spring binstub --all"
    run "#{@rvm} do bundle exec spring binstub --all"
  end
end

#
# Generate and Setup
#

after_bundle do
  puts "Run generators".cyan

  # Keep the rspec generator from hanging.
  # @see (http://www.sitepoint.com/rails-application-templates-real-world/)
  run "#{@rvm} do spring stop"

  run "#{@rvm} do rails generate rspec:install"

  if yes?("Create Users? [yN]".cyan)
    run "#{@rvm} do rails generate authlogic:install"
    run "#{@rvm} do rake db:create"
    run "#{@rvm} do rake db:migrate"
  end

  if yes?("Initialize the Bitbucket Git repository? [yN]".cyan)
    require 'json'

    # Create Bitbucket Repository
    # @see https://confluence.atlassian.com/display/BITBUCKET/repository+Resource#repositoryResource-POSTanewrepository
    data = {
      scm: 'git',
      is_private: true,
      forking_policy: 'allow_forks',
      name: app_name.titleize,
      language: 'ruby'
    }
    repo_slug = @app_name.titleize.parameterize
    owner = 'tiu'
    credentials = ask("What are your TIU Bitbucket credentials? (username:password)".cyan).strip # TODO: can we drop this prompt?
    # --user 'username:password'
    # --pubkey ~/.ssh/id_rsa.pub # TODO: can we make this work???
    # TODO: what if this fails? can we re-try?
    run "curl --request POST --user '#{credentials}' --header 'Content-Type: application/json' https://bitbucket.org/api/2.0/repositories/#{owner}/#{repo_slug} --data '#{data.to_json}'"

    # Open in SourceTree (assumes command line is already installed)
    # Not cross-platform compatible.
    # @see (http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby)
    # @see (http://stackoverflow.com/questions/19663202/how-do-you-open-sourcetree-from-the-command-line)
    if `which stree`
      `stree`
    else
      puts "Go install the SourceTree Command Line Tools. Simply launch SourceTree, open the SourceTree menu, and select \"Install Command Line Tools\".".yellow
      `open -a SourceTree #{destination_root}`
    end

    # Add code to the repository
    git :init
    git add: '--all .', commit: "-m 'Applied Rails Application Template'"
    git remote: "add origin ssh://git@bitbucket.org/#{owner}/#{@app_name.titleize.parameterize}.git"
    git push: "-u origin --all"

    if yes?("Deploy? [yN]".cyan)
      # Add deploy keys to Bitbucket repository
      # @see https://confluence.atlassian.com/display/BITBUCKET/deploy-keys+Resource#deploy-keysResource-POSTanewkey
      key = `ssh dev.tiu11.org "cat ~/.ssh/id_rsa.pub"`
      label = key.split(' ')[2]
      data = {
        key: key,
        label: label
      }
      run "curl --request POST --user '#{credentials}' --header 'Content-Type: application/json' https://bitbucket.org/api/1.0/repositories/#{owner}/#{repo_slug}/deploy-keys --data '#{data.to_json}'"

      run "cap dev deploy"
      # TODO: cap dev nginx:setup
      # TODO: cap dev postgres:setup
    end
  end
end

say_status :end, "#{@app_name} Complete!"
