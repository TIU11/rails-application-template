namespace :deploy do
  # TODO:
  # * Requires sudo access. Use daemons that can handle this without root-level permissions
  # * invoke 'rvm:create_gemset', which currently needs to be invoked separately as a top-level task
  # * consider moving to another ruby version manager
  desc 'First-deploy server setup'
  task :setup do
    invoke 'deploy:check'
    invoke 'ubuntu:setup'
    invoke 'postgresql:setup'
    invoke 'nginx:setup'
  end
end
