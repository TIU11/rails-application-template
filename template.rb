# Download template files
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"

gsub_file 'lib/custom_public_exceptions.rb', "%@app_name%", @app_name.underscore.camelize

# Configurations

insert_into_file 'config/application.rb', open('config/application.rb.delta').read, after: "config.assets.version = '1.0'"
remove_file 'config/application.rb.delta'
gsub_file 'config/application.rb', "# config.time_zone = 'Central Time (US & Canada)'", "config.time_zone = 'Eastern Time (US & Canada)'"
gsub_file 'config/application.rb', "[:password]", "[:password, :password_confirmation]"

insert_into_file 'Gemfile', open('Gemfile.delta').read, before: '# Gems used only for assets and not required'
remove_file 'Gemfile.delta'

copy_file "#{destination_root}/config/environments/production.rb", "#{destination_root}/config/environments/dev.rb"
copy_file "#{destination_root}/config/environments/production.rb", "#{destination_root}/config/environments/demo.rb"
uncomment_lines "config/environments/production.rb", "config.force_ssl = true"

gsub_file 'config/deploy.rb', "set your application name here", @app_name.parameterize

gsub_file 'config/initializers/exception_notification.rb', "APP SHORT NAME", @app_name.titleize

route "root to: 'exception#show'"
route "match '/404' => 'exception#show'"

#
# Remove Junk
#
remove_file 'app/assets/images/rails.png'
remove_file 'public/index.html'

#
# Generate and Setup
#
generate 'bootstrap:install less'
generate 'rspec:install'

if yes?("Initialize the Bitbucket Git repository? (yN)")
  require 'json'

  # Create Bitbucket Repository
  # @see https://confluence.atlassian.com/display/BITBUCKET/repository+Resource#repositoryResource-POSTanewrepository
  data = {
    scm: 'git',
    is_private: true,
    forking_policy: 'allow_forks',
    name: app_name,
    language: 'ruby'
  }
  repo_slug = @app_name.parameterize
  owner = 'tiu'
  credentials = ask("What are your TIU Bitbucket credentials? (username:password)").strip # TODO: can we drop this prompt?
  # --user username:password
  # --pubkey ~/.ssh/id_rsa.pub # TODO: can we make this work???
  run "curl --request POST --user #{credentials} --header 'Content-Type: application/json' https://bitbucket.org/api/2.0/repositories/#{owner}/#{repo_slug} --data '#{data.to_json}'"

  # Add code to the repository
  git :init
  git add: '--all .', commit: "-m 'Applied Rails Application Template'"
  git remote: "add origin ssh://git@bitbucket.org/#{owner}/#{@app_name.parameterize}.git"
  git push: "-u origin --all"

  if yes?("Deploy? (yN)")
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
