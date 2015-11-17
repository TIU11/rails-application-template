# See https://github.com/railscasts/373-zero-downtime-deployment/blob/master/blog-after/config/recipes/postgresql.rb

set_default(:pg_host, "localhost")
set_default(:pg_user) { "#{fetch(:application)}_#{rails_env}" }
set_default(:pg_password) { Capistrano::CLI.password_prompt "#{rails_env.upcase} PostgreSQL Password: " }
set_default(:pg_database) { "#{application}_#{rails_env}" }

namespace :postgresql do
  desc "Create a database for this application."
  task :create_database do
    on roles(:db) do
      run %Q{#{sudo} -u postgres psql -c "create user \\"#{pg_user}\\" with password '#{pg_password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database \\"#{pg_database}\\" owner \\"#{pg_user}\\";"}
    end
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Create database user"
  task :create_db_user do
    on roles(:db) do
      unless psql '-c', %Q{"create user \\"#{fetch(:pg_user)}\\" with password '#{fetch(:pg_password)}';"}
        error 'postgresql: creating database user failed!'
        exit 1
      end
    end
  end
end
