# http://stackoverflow.com/questions/312214/how-do-i-run-a-rake-task-from-capistrano
namespace :deploy do

  desc "Run a rake task on a remote server, 'cap deploy:invoke[db:migrate,VERSION=1234567890]'"
  task :invoke, [:arg1, :arg2] => [:set_rails_env] do |task, args|
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args[:arg1], args[:arg2]
        end
      end
    end
  end

end
