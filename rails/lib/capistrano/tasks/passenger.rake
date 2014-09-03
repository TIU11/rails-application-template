namespace :deploy do
  desc "Change group to www-data"
  task :update_group do
    on roles(:app) do
      execute :sudo, :chown, "-Rh `whoami`:www-data #{deploy_to}"
      execute :sudo, :chmod, "-R g+w #{deploy_to}"
    end
  end
end
