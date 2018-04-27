# frozen_string_literal: true

namespace :deploy do
  desc "Change group to www-data"
  task :update_group do
    on roles(:app) do
      info "Give group 'www-data' ownership of files"
      execute :sudo, :chown, "-Rh `whoami`:www-data #{deploy_to}"
      execute :sudo, :chmod, "-R g+w #{deploy_to}"
    end
  end

  before 'passenger:restart', 'deploy:update_group'
end
