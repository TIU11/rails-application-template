# Download template files
git archive: "--remote=git@bitbucket.org:tiu/rails-application-template.git --format=tar --verbose master:rails | (tar xf -)"

gsub_file 'lib/custom_public_exceptions.rb', "%@app_name%", @app_name.underscore.camelize

insert_into_file 'config/application.rb', open('config/application.rb.delta').read, after: "config.assets.version = '1.0'"
remove_file 'config/application.rb.delta'
gsub_file 'config/application.rb', "# config.time_zone = 'Central Time (US & Canada)'", "config.time_zone = 'Eastern Time (US & Canada)'"
gsub_file 'config/application.rb', "[:password]", "[:password, :password_confirmation]"

insert_into_file 'Gemfile', open('Gemfile.delta').read, before: '# Gems used only for assets and not required'
remove_file 'Gemfile.delta'

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
