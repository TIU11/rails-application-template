# See https://github.com/railscasts/373-zero-downtime-deployment/blob/master/blog-after/config/recipes/postgresql.rb

set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "#{rails_env.upcase} PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }

namespace :postgresql do
  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user \\"#{postgresql_user}\\" with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database \\"#{postgresql_database}\\" owner \\"#{postgresql_user}\\";"}
  end
  after "deploy:setup", "postgresql:create_database"
end
