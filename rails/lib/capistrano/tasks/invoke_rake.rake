# http://stackoverflow.com/questions/312214/how-do-i-run-a-rake-task-from-capistrano
namespace :deploy do

  desc "Run a task on a remote server, 'cap deploy:invoke[db:migrate:status]'"
  task :invoke, [:task] => [:set_rails_env] do |t, args|
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args[:task]
        end
      end
    end
  end

end
