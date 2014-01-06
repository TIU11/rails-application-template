# Check prerequisite gems
%w{colored}.each do |gemname|
  if Gem::Specification.find_all_by_name(gemname).empty?
    run "gem install #{gemname}"
    Gem.refresh
    Gem.activate(gemname)
  end
end

require 'colored'
require 'rails'

RAILS4 = Rails.version > "4.0.0"
say_status :rails_version, Rails.version

# Download template files
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"

# Configurations

insert_into_file 'config/application.rb', open('config/application.rb.delta').read, after: "config.assets.version = '1.0'"
gsub_file 'config/application.rb', "# config.time_zone = 'Central Time (US & Canada)'", "config.time_zone = 'Eastern Time (US & Canada)'"
gsub_file 'config/application.rb', "[:password]", "[:password, :password_confirmation]"
remove_file 'config/application.rb.delta'

# Gemfile
if RAILS4 # delete Rails 3 sections
  insert_into_file 'Gemfile', open('Gemfile.delta').read, before: 'group :doc do'
  gsub_file 'Gemfile', /RAILS3-(.*?)-RAILS3\n/m, ''
  gsub_file 'Gemfile', /-?RAILS4-?\n?/, ''
  comment_lines 'Gemfile', "turbolinks"
  comment_lines 'Gemfile', "jbuilder"
else # Delete Rails 4 sections
  insert_into_file 'Gemfile', open('Gemfile.delta').read, before: '# Gems used only for assets and not required'
  gsub_file 'Gemfile', /RAILS4-(.*?)-RAILS4\n/m, ''
  gsub_file 'Gemfile', /-?RAILS3-?\n?/, ''
end
remove_file 'Gemfile.delta'

copy_file "#{destination_root}/config/environments/production.rb", "#{destination_root}/config/environments/dev.rb"
copy_file "#{destination_root}/config/environments/production.rb", "#{destination_root}/config/environments/demo.rb"
uncomment_lines "config/environments/production.rb", "config.force_ssl = true"
gsub_file "#{destination_root}/app/assets/javascripts/application.js", "//= require turbolinks", '' if RAILS4

route "root to: 'exception#show'"
route "match '/404' => 'exception#show'"

# Process Templates
template "#{destination_root}/config/locales/en.yml.tt"
template "#{destination_root}/config/initializers/exception_notification.rb.tt"
template "#{destination_root}/lib/custom_public_exceptions.rb.tt"
template "#{destination_root}/config/deploy.rb.tt"

#
# Remove Junk
#
remove_file 'app/assets/images/rails.png'
remove_file 'public/index.html'

#
# Create and initialize gemset
# @see https://rvm.io/workflow/scripting for explanation of `rvm do`
#
puts "Setting up RVM gemset and installing bundled gems (may take a while)".cyan.bold.bold
current_ruby = `rvm current`.strip
desired_ruby = ask("Which RVM Ruby would you like to use? [#{current_ruby}]".cyan.bold)
desired_ruby = current_ruby if desired_ruby.blank?
gemset_name = app_name.titleize.parameterize
run "rvm install #{desired_ruby}"
run "rvm #{current_ruby} do rvm --ruby-version --create use #{desired_ruby}@#{gemset_name}"
@rvm = "rvm #{desired_ruby}@#{gemset_name}"
run "#{@rvm} do bundle install"

run "#{@rvm} do rails generate bootstrap:install less"
run "#{@rvm} do rails generate rspec:install"

#
# Generate and Setup
#

if yes?("Create Users? [yN]".cyan.bold)
  run "#{@rvm} do rails generate authlogic:install"
end

if yes?("Initialize the Bitbucket Git repository? [yN]".cyan.bold)
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
  credentials = ask("What are your TIU Bitbucket credentials? (username:password)".cyan.bold).strip # TODO: can we drop this prompt?
  # --user username:password
  # --pubkey ~/.ssh/id_rsa.pub # TODO: can we make this work???
  run "curl --request POST --user #{credentials} --header 'Content-Type: application/json' https://bitbucket.org/api/2.0/repositories/#{owner}/#{repo_slug} --data '#{data.to_json}'"

  # Add code to the repository
  git :init
  git add: '--all .', commit: "-m 'Applied Rails Application Template'"
  git remote: "add origin ssh://git@bitbucket.org/#{owner}/#{@app_name.titleize.parameterize}.git"
  git push: "-u origin --all"

  if yes?("Deploy? [yN]".cyan.bold)
    # Add deploy keys to the repository
    key = `ssh dev.tiu11.org "cat ~/.ssh/id_rsa.pub"`
    label = key.split(' ')[2]
    data = {
      key: key,
      label: label
    }
    run "curl --request POST --user #{credentials} --header 'Content-Type: application/json' https://bitbucket.org/api/1.0/repositories/#{owner}/#{repo_slug}/deploy-keys --data '#{data.to_json}'"

    run "cap dev deploy:setup" # TODO: nginx configuration
    run "cap dev deploy"
  end
end

say_status :end, "#{@app_name} Complete!"
