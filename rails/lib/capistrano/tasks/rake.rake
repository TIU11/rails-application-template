# http://stackoverflow.com/questions/312214/how-do-i-run-a-rake-task-from-capistrano
desc "Run a rake task on a remote server, 'cap production rake[db:migrate,VERSION=1234567890]'"
task :rake, [:arg1, :arg2] => ['deploy:set_rails_env'] do |_task, args|
  on primary fetch(:migration_role) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, args[:arg1], args[:arg2]
      end
    end
  end
end
